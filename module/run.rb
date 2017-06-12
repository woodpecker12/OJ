module Run

  def Run.cmd(dir, cmd)
    begin
      currentDir = Dir.getwd

      Dir.chdir(dir)
      io = IO.popen(cmd)
      Dir.chdir(currentDir)

      io.readlines
    rescue => ex
      puts ex.message
      io.close
    end
  end

end