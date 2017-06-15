require 'open3'

module Run

  def Run.cmd(dir, cmd)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    out = nil
    err = nil
    status = nil

    begin
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
        out = stdout.read
        err = stderr.read
        status = wait_thread.value.to_i
      end
    rescue => ex
      raise SystemError.new(ex.message)
    end

    Dir.chdir(currentDir)

    if !err.empty?
      return err
    elsif status > 0
      raise SystemError.new(err)
    else
      return out
    end

  end

end