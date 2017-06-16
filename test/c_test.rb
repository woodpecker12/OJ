require_relative '../module/run'
require_relative '../module/file_manager'
require_relative '../module/log'
require_relative 'test_result'
require_relative '../base/environment'
require_relative '../exception/exception'

class CTest
  include Run
  include FileManager
  include Log

  def initialize(id, codeSource, testCase, result)
    @id = id
    @codeSource = codeSource
    @testCase = testCase
    @result = result
  end

  def run()
    compile
    runTest
  end

  def compile()
    codeFile = @id + ".c"
    @binFile = File.basename(codeFile, ".*")
    compileCmd = "gcc -o #{@binFile} ../code/#{codeFile}"
    compileLog = "log/#{@binFile}.log"

    begin
      Log.dbg('compiling...')
      FileManager.write(SOURCE_CODE_ROOT + codeFile, @codeSource)
      out, err= Run.cmd(BIN_FILE_ROOT, compileCmd)
      unless out.empty?
        FileManager.write(compileLog, out)
        raise CompileError.new("compile error")
      end
      Log.dbg("compile done!!! bin file => target/#{@binFile}")
    rescue => log
      Log.dbg("compile error!!! to view compile log => #{compileLog}")
      raise CompileError.new(log.message)
    end
  end

  def functionTest(caseName, inputList, output)
    begin
      Log.dbg("#{caseName} => running function test...")
      p @testCase.memLimit
      cmd = "../timeout -m #{@testCase.memLimit} ./#{@binFile}"
      result, err = Run.cmd(BIN_FILE_ROOT, cmd, inputList, @testCase.timeLimit)
      errSplit = err.split(" ")
      if errSplit[0] == "MEM"
        raise MemFlow.new("mem actul use #{errSplit[6]}, expect #{@testCase.memLimit}")
      end
    rescue MemFlow => memFlow
      @result.mem(caseName, memFlow.message)
      return
    rescue TimeoutError => timeoutErr
      @result.time(caseName, "time out for expect time: #{@testCase.timeLimit}")
      return
    rescue => ex
      raise RunError.new(ex.message)
    end

    unless result == output
      @result.function(caseName, "expect: #{output}, actul: #{result}")
    end
  end

  def runTest()
    Log.dbg('running all test...')

    begin
      testInOutList = @testCase.fetchTestCase
      testInOutList.each_key do |caseName|
        input = testInOutList[caseName][0]
        output = testInOutList[caseName][1]

        functionTest(caseName, input, output)
      end
    rescue RunError => runErr
      Log.dbg("run #{@binFile} test error: ")
      Log.dbg(runErr.message)
      raise runErr
    rescue => ex
      raise SystemError.new(ex.message)
    end
  end

  private :compile
  private :runTest
  private :functionTest

end