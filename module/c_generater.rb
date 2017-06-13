require_relative 'run'
require_relative '../exception/compile_error'
require_relative 'file_manager'
require_relative 'log'

module CGenerater
  include Run
  include FileManager
  include Log

  @@defaulBinPath = "target/"

  def CGenerater.compile(codeSource)
    binName = File.basename(codeSource, ".*")

    begin
      Log.dbg('compiling...')
      out = Run.cmd(@@defaulBinPath, "gcc -o #{binName} ../code/#{codeSource}")
      FileManager.write("log/#{binName}.log", out)
    rescue => log
      Log.dbg("compile error!!! to view compile log => log/#{binName}.log")
      FileManager.write("log/#{binName}.log", log.message)
      raise CompileError.new(log.message)
    end

    Log.dbg("compile done!!! bin file => target/#{binName}")
  end

  def CGenerater.run(codeSource)
    binName = File.basename(codeSource, ".*")

    begin
      Log.dbg('running all test...')
      Run.cmd(@@defaulBinPath, "./#{binName}")
    rescue => ex
      Log.dbg("Run #{binName} error: ")
      Log.dbg(ex.message)

      return RESULT_ERROR
    end

    Log.dbg("all test pass!!!")
  end

end