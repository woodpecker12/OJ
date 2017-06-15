require_relative 'module/run'
require_relative 'exception/compile_error'
require_relative 'module/file_manager'
require_relative 'module/log'
require_relative 'test_result'

class CGenerater
  include Run
  include FileManager
  include Log

  @@binFilePath = "target/"

  def initialize(codeFile, testCaseList, timeLimit, memLimit, result)
    @codeFile = codeFile
    @binFile = File.basename(@codeFile, ".*")
    @testCaseList = testCaseList
    @timeLimit = timeLimit
    @memLimit = memLimit
    @result = result
  end

  def compile()
    compileCmd = "gcc -o #{@binFile} ../code/#{@codeFile}"
    compileLog = "log/#{@binFile}.log"

    begin
      Log.dbg('compiling...')
      out = Run.cmd(@@binFilePath, compileCmd)
      FileManager.write(compileLog, out)
      Log.dbg("compile done!!! bin file => target/#{@binFile}")
    rescue => log
      Log.dbg("compile error!!! to view compile log => #{compileLog}")
      FileManager.write(compileLog, log.message)
      raise CompileError.new(log.message)
    end
  end

  def functionTest(input, output, caseName)
    Log.dbg("#{caseName} => running function test...")
    result = Run.cmd(@@binFilePath, "./#{@binFile} #{input}")
    if result == output
      @result.function(caseName, PASS)
      return true
    else
      Log.dbg("test #{caseName} fail : expect[#{output}], actual[#{result}]")
      @result.function(caseName, "#{FAIL}: expect[#{output}], actul[#{result}]")
      return false
    end
  end

  def memTest(caseName, input)
    Log.dbg("#{caseName} => running mem test...")
    result = Run.getErr(@@binFilePath, "../timeout -m #{@memLimit} ./#{@binFile} #{input}")
    if result.include?("FINISHED")
      @result.mem(caseName, PASS)
      return true
    else
      @result.mem(caseName, FAIL)
      return false
    end
  end

  def timeTest(caseName, input)
    Log.dbg("#{caseName} => running time test...")
    result = Run.getErr(@@binFilePath, "../timeout -t #{@timeLimit} ./#{@binFile} #{input}")
    if result.include?("FINISHED")
      @result.time(caseName, PASS)
      return true
    else
      @result.time(caseName, FAIL)
      return false
    end
  end

  def runTest()
    Log.dbg('running all test...')

    begin
      @testCaseList.each do |caseName|
        testIn = "test/#{@binFile}/#{caseName}.in"
        testOut = "test/#{@binFile}/#{caseName}.out"

        unless File.exist?(testIn) and File.exist?(testOut) then
          @result.function(caseName, TEST_FILE_ERROR)
          next
        end

        input = File.open(testIn).readline
        output = File.open(testOut).readline

        next unless functionTest(input, output, caseName)
        next unless memTest(caseName, input)
        next unless timeTest(caseName, input)

      end
      @result.dump
    rescue => ex
      Log.dbg("run #{@binFile} test error: ")
      Log.dbg(ex.message)

      return SYSTEM_ERROR
    end
  end

end