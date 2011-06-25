module ZZSharedLib
  class DeployGroupSimpleDB < RightAws::ActiveSdb::Base
    set_domain_name "deploy"

    columns do
      zz_object_type
      group
      config_json
      recipes_deploy_tag
      app_deploy_tag
      created_at    :default => lambda{ Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') }
      updated_at
    end

    def self.object_type
      @@object_type ||= 'deploy_group_type'.freeze
    end

    def config
      @config ||= JSON.parse(self.config_json).recursively_symbolize_keys!
    end

    def config=(object)
      self.config_json = JSON.fast_generate(object)
    end

    def save
      self.updated_at = Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
      super
    end
  end
end
