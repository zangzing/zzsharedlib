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
end
