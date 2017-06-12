module FileManager

  def FileManager.write(filePath, str)

    begin
      io = File.open(filePath, "w")
      io.print(str)
      io.close
    rescue => ex
      puts ex.message
      io.close
    end
  end

end