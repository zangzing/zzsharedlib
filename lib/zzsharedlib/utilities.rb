module ZZSharedLib
  # run a command line and echo to console
  def do_cmd(cmd)
    puts cmd
    Kernel.system(cmd)
  end

  # same as above but returns the result code
  # 0 is success, anything else is an error code
  def do_cmd_result(cmd)
    do_cmd(cmd)
    $?.exitstatus
  end
end
