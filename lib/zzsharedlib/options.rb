module ZZSharedLib
  # tracks the global and per command options but lets you
  # fetch values without regard to which one.  The command
  # is checked before the global
  class Options
    def self.global_options=(options)
      @@global_options = options
    end

    def self.cmd_options=(options)
      @@cmd_options = options
    end

    def self.cmd_options
      @@cmd_options ||= {}
    end

    def self.global_options
      @@global_options ||= {}
    end

    def self.get(option)
      v = cmd_options[option]
      return v if !v.nil?

      v = global_options[option]
      return v
    end
  end
end