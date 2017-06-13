require 'open3'

require_relative 'log'

module Run
  include Log

  def Run.cmd(dir, cmd)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    out = nil
    err = nil
    status = nil

    Log.dbg("in dir => #{dir}")

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      out = stdout.read
      err = stderr.read
      status = wait_thread.value.to_i
    end

    Dir.chdir(currentDir)

    if status > 0
      raise err
    else
      return out
    end

  end

end