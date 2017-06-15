require 'find'
require 'fileutils'

require_relative 'log'

module FileManager
  include Log

  def FileManager.write(filePath, str)

    begin
      io = File.open(filePath, "w")
      io.print(str)
      io.close
    rescue => ex
      Log.dbg(ex.message)
      raise ex.message
    end
  end

  def FileManager.fileList(dir)
    list = []
    Find.find(dir) do |fileName|
      list << File.basename(fileName)
    end

    return list[1..-1]
  end

  def FileManager.delete(path)
    FileUtils.rm_rf(path)
  end

  def FileManager.mkdir(dir)
    Dir.mkdir(dir) unless Dir.exist?(dir)
  end

end