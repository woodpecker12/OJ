require 'open3'

module Run

  def Run.cmd(dir, cmd, inputList = [], timeout = 30)
    currentDir = Dir.getwd
    Dir.chdir(dir)

    out = ""
    err = ""
    status = 0

    stdout = nil

    begin
      Timeout.timeout(timeout) do
        stdin, stdout, stderr, wait_thread = Open3.popen3(cmd)

        # sleep(1)
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
      out = stdout.read
      raise SystemError.new(ex.message) if out.empty?
    ensure
      Dir.chdir(currentDir)
      return out, err, status
    end
    # p out
    # p err
  end

end