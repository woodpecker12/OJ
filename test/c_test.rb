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
      out = Run.cmd(BIN_FILE_ROOT, compileCmd)
      unless out.empty? then
        FileManager.write(compileLog, out)
        raise CompileError.new("compile error")
      end
      Log.dbg("compile done!!! bin file => target/#{@binFile}")
    rescue => log
      Log.dbg("compile error!!! to view compile log => #{compileLog}")
      raise CompileError.new(log.message)
    end
  end

  def functionTest(caseName, input, output)
    begin
      Log.dbg("#{caseName} => running function test...")
      result = Run.cmd(BIN_FILE_ROOT, "./#{@binFile} #{input}")
    rescue => ex
      raise RunError.new(ex.message)
    end

    if result == output
      @result.function(caseName, PASS)
      return true
    else
      Log.dbg("test #{caseName} fail : expect[#{output}], actual[#{result}]")
      @result.function(caseName, RESULT_ERROR)
      return false
    end

  end

  def memTest(caseName, input)
    begin
      Log.dbg("#{caseName} => running mem test...")
      result = Run.cmd(BIN_FILE_ROOT, "../timeout -m #{@testCase.memLimit} ./#{@binFile} #{input}")
    rescue => ex
      raise RunError.new(ex.message)
    end

    if result.include?("FINISHED")
      @result.mem(caseName, PASS)
      return true
    else
      @result.mem(caseName, MEM_FLOW)
      return false
    end
  end

  def timeTest(caseName, input)
    begin
      Log.dbg("#{caseName} => running time test...")
      result = Run.cmd(BIN_FILE_ROOT, "../timeout -t #{@testCase.timeLimit} ./#{@binFile} #{input}")
    rescue => ex
      raise RunError.new(ex.message)
    end

    if result.include?("FINISHED")
      @result.time(caseName, PASS)
      return true
    else
      @result.time(caseName, RUN_TIME_OUT)
      return false
    end
  end

  def runTest()
    Log.dbg('running all test...')

    begin
      testInOutList, invalidTestList = @testCase.fetchTestCase
      testInOutList.each_key do |caseName|
        input = testInOutList[caseName][0]
        output = testInOutList[caseName][1]

        next unless functionTest(caseName, input, output)
        next unless memTest(caseName, input)
        next unless timeTest(caseName, input)

      end
    rescue RunError => runErr
      Log.dbg("run #{@binFile} test error: ")
      Log.dbg(runErr.message)
      raise runErr
    rescue => ex
      raise SystemError.new(ex.message)
    end
  end

end