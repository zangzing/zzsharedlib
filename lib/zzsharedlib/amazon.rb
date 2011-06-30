require 'logger'

# this class manages global stuff related to the amazon connection
module ZZSharedLib

  class Amazon
    attr_reader :ec2

    def self.ec2
      @@ec2 ||= RightAws::Ec2.new(access_key, secret_key, :endpoint_url => 'https://ec2.us-east-1.amazonaws.com/', :logger => Amazon.logger)
    end

    def self.secret_key
      Options.get(:secret_key) || ENV['AWS_SECRET_ACCESS_KEY']
    end

    def self.access_key
      Options.get(:access_key) || ENV['AWS_ACCESS_KEY_ID']
    end

    def self.log_level
      Options.get(:log_level) || Logger::Severity::WARN
    end

    def self.make_logger
      # need to pass in a logdev for this to work...
      logger = Logger.new(STDOUT)
      logger.level = log_level
      logger
    end

    def self.logger
      @@logger ||= make_logger
    end

    def initialize(ec2 = nil)
      connection = RightAws::ActiveSdb.establish_connection(Amazon.access_key, Amazon.secret_key, :logger => Amazon.logger)
      if ec2.nil?
        @ec2 = Amazon.ec2
      else
        @ec2 = ec2
      end
    end

    # get the deploy group object from the simple db
    def find_deploy_group(group_name)
      # first see if already exists
      deploy_group = DeployGroupSimpleDB.find_by_zz_object_type_and_group(DeployGroupSimpleDB.object_type, group_name, :auto_load => true)

      if deploy_group.nil? || deploy_group[:group] != group_name
        raise "Deploy group not found.  Make sure you specified the correct deploy group name."
      end

      deploy_group
    end

    # does a describe and returns the map, if we already have it and not doing force
    # return what we already have
    # we filter out any terminated instances
    def describe_tags(force = false)
      return @describe_tags if force == false && !@describe_tags.nil?

      # grab it all and filter later
      all_tags = ec2.describe_tags

      # filter out any terminated instances
      instances = ec2.describe_instances
      terminated_instances = Set.new
      instances.each do |instance|
        if instance[:aws_state] == 'terminated'
          terminated_instances << instance[:aws_instance_id]
        end
      end
      filtered_tags = []
      all_tags.each do |tag|
        resource_id = tag[:resource_id]
        filtered_tags << tag unless terminated_instances.include?(resource_id)
      end

      return @describe_tags = filtered_tags
    end

    # return all the tags that match a given resource id
    def tags_for_resource(id)
      tags = []
      id = id.to_s
      describe_tags.each do |tag|
        tags << tag if id == tag[:resource_id]
      end

      return tags
    end

    # flatten the key/values into a top level hash
    # assumes all tags are for the same resource id
    def flat_tags_for_resource(id)
      tags = tags_for_resource(id)
      flat = {}
      tags.each do |tag|
        key = tag[:key]
        value = tag[:value]
        flat[key.to_sym] = value
      end

      return flat
    end

    # find an exact match for a given resource type, key, and value
    # returns a list of the resource_ids that matched
    def find_typed_resource(type, key, value)
      ids = []
      type = type.to_s
      key = key.to_s
      value = value.to_s
      describe_tags.each do |tag|
        if type == tag[:resource_type] && key == tag[:key] && value == tag[:value]
          ids << tag[:resource_id]
        end
      end

      return ids
    end

    # finds instances within a group/app by a role
    def find_by_role(group, role)
      match_role = find_typed_resource("instance", :role, role)
      match_group = find_typed_resource("instance", :group, group)
      # find the ones that match all three
      match = match_role & match_group
    end

    # find with filters and sort by Name, returns
    # array of maps with
    # [{:resource_id => inst_id, :Name => "Instance Name"},...]
    #
    def find_and_sort_named_instances(group = nil, role = nil, ready_only = true)
      instances = {}
      describe_tags.each do |tag|
        if "instance" == tag[:resource_type]
          resource_id = tag[:resource_id]
          inst = instances[resource_id]
          if inst.nil?
            inst = { :resource_id => resource_id }
            instances[resource_id] = inst
          end
          key = tag[:key].to_sym
          value = tag[:value]
          inst[key] = value
        end
      end

      # ok, we've collected the data now we need to filter it
      filtered_instances = []
      need_describe = []
      instances.each_value do |inst|
        next if inst[:group].nil? ||(group.nil? == false && inst[:group] != group.to_s)
        next if inst[:role].nil? || (role.nil? == false && inst[:role] != role.to_s)
        next if ready_only && inst[:state] != "ready"
        filtered_instances << inst
        need_describe << inst[:resource_id]
      end
      filtered_instances.sort! { |a,b| a[:Name] <=> b[:Name] }

      # last step is to describe the instances we care about to get
      # more info and add that to each instance returned
      az_instances = ec2.describe_instances(need_describe)
      az_hash = {}
      az_instances.each do |instance|
        key = instance[:aws_instance_id]
        az_hash[key] = instance
      end
      # now update the info on filtered instances
      filtered_instances.each do |instance|
        inst_id = instance[:resource_id]
        detail = az_hash[inst_id]
        instance[:public_hostname] = detail[:dns_name]
        instance[:local_hostname] = detail[:private_dns_name]
      end
      return filtered_instances
    end

    # similar to find_and_sort_named_instances but
    # returns a hash with the instance id as the key
    # for each element
    #
    # {:instance_id => { :Name => "Instance Name", :role => role},...}
    #
    def find_named_instances(group = nil, role = nil, ready_only = true)
      remapped = {}
      instances = find_and_sort_named_instances(group, role)
      instances.each do |instance|
        key = instance[:resource_id].to_sym
        remapped[key] = instance
      end
      return remapped
    end

  end

end
