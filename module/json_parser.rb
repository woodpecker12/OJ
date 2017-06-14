require 'rubygems'
require 'json'

module JsonParser

  def JsonParser.parse(jsonPath)
    begin
      io = File.read(jsonPath)
      JSON.parse(io)
    rescue => ex
      puts ex.message
      io.close
    end
  end

end