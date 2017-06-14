require 'find'

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

  def FileManager.fileList(dir)
    list = []
    Find.find(dir) do |fileName|
      list << File.basename(fileName)
    end

    return list[1..-1]
  end

end