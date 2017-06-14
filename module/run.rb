require 'open3'

require_relative 'log'

module Run
  include Log

  def Run.getErr(dir, cmd)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    err = nil

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      err = stderr.read
    end

    Dir.chdir(currentDir)

    return err

  end

  def Run.cmd(dir, cmd)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    out = nil
    err = nil
    status = nil

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      out = stdout.read
      err = stderr.read
      status = wait_thread.value.to_i
    end

    Dir.chdir(currentDir)

    if status > 0 and !err.empty?
      raise err
    else
      return out
    end

  end

end