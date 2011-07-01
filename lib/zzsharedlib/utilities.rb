module ZZSharedLib
  class CL
    # run a command line and echo to console
    def self.do_cmd(cmd)
      puts cmd
      Kernel.system(cmd)
    end

    # same as above but returns the result code
    # 0 is success, anything else is an error code
    def self.do_cmd_result(cmd)
      do_cmd(cmd)
      $?.exitstatus
    end
  end

  class Utils
    READY = "ready".freeze
    ERROR = "error".freeze
    START = "deploying".freeze
    NEVER = "never".freeze
    RESTARTING = "restarting".freeze
    OK_TO_DEPLOY_STATES = [NEVER, READY, ERROR].freeze

    def initialize(amazon)
      @amazon = amazon
    end

    # mark the deploy state of all unless already marked
    # as errors so we don't overwrite that state
    def mark_deploy_state(instances, state_tag, state, keep_error_state = false)
      to_tag = []
      instances.each do |instance|
        inst_id = instance[:resource_id]
        if keep_error_state
          tags = @amazon.flat_tags_for_resource(inst_id)
          deploy_tag = tags[state_tag]
          if !deploy_tag.nil? && deploy_tag != ERROR
            to_tag << inst_id
          end
        else
          to_tag << inst_id
        end
      end
      @amazon.ec2.create_tags(to_tag, {state_tag => state })
    end

    def check_deploy_state(instances, state_tag)
      instances.each do |instance|
        inst_id = instance[:resource_id]
        tags = @amazon.flat_tags_for_resource(inst_id)
        deploy_tag = tags[state_tag]
        if !deploy_tag.nil? && !OK_TO_DEPLOY_STATES.include?(deploy_tag)
          raise "One or more instances is still marked as deploying, we will not deploy again.  You can use --force to override"
        end
      end
    end
  end

end
