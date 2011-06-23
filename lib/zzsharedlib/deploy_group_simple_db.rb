module ZZSharedLib
  class DeployGroupSimpleDB < RightAws::ActiveSdb::Base
    set_domain_name "deploy"

    columns do
      zz_object_type
      group_name
      config_json
      recipes_deploy_tag
      app_deploy_tag
      created_at    :DateTime, :default => lambda{ Time.now }
    end

    def self.object_type
      @@object_type ||= 'deploy_group_type'.freeze
    end

    def config
      @config ||= JSON.parse(self.config_json).recursively_symbolize_keys!
    end

    def config=(object)
      self.config_json = JSON.pretty_generate(object)
    end
  end
end
