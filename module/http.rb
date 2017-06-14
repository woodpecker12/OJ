require 'open-uri'

module Http

  def Http.getFile(httpUrl, savePath)

    begin
      fp = File.open(savePath, "wb")
      fp.write(open(httpUrl).read)
      fp.close
    rescue => ex
      File.delete(savePath) if File.exist?(savePath)
      raise ex.message
    end
  end

end