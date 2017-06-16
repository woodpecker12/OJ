require 'open3'

module Run

  def Run.cmd(dir, cmd, inputList = [], timeout = 30)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    out = nil
    err = nil
    status = nil

    begin
      timeout(timeout) do
        stdin, stdout, stderr, wait_thread = Open3.popen3(cmd)

        inputList.each do |input|
          stdin.puts(input)
        end
        out = stdout.read
        err = stderr.read
        status = wait_thread.value.to_i

      end
    rescue TimeoutError =>  timeoutErr
      raise timeoutErr
    rescue => ex
      raise SystemError.new(ex.message)
    end

    Dir.chdir(currentDir)
    # p out
    # p err
    # p status

    return out unless out.empty?
    return err unless err.empty?
    raise SystmeError.new(err) if status > 0
    return ""

  end

end