require_relative '../module/run'
require_relative '../module/file_manager'
require_relative '../module/log'
require_relative 'test_result'
require_relative '../base/environment'
require_relative '../exception/exception'
require_relative 'cpp_check'

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
    check = CppCheck.new
    @result.cppCheck check.run(SOURCE_CODE_ROOT, @id + ".c")
    check.score
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
      out, err, status = Run.cmd(BIN_FILE_ROOT, compileCmd)
      if !out.empty? or status != 0
        FileManager.write(compileLog, out)
        raise CompileError.new("compile error")
      end
      Log.dbg("compile done!!! bin file => target/#{@binFile}")
    rescue => log
      Log.dbg("compile error!!! to view compile log => #{compileLog}")
      raise CompileError.new(log.message)
    end
  end

  def checkHeapUsed(err)
    actulUsed = err[/[\d*,]*\d\sbytes\sallocated/][/[\d*,]*\d/].delete(",").to_i
    raise MemFlow.new("expect mem: #{@testCase.memLimit}, actul: #{actulUsed}") if actulUsed > @testCase.memLimit
  end

  def functionTest(caseName, inputList, output)
    begin
      Log.dbg("#{caseName} => running function test...")
      cmd = "valgrind ./#{@binFile}"
      out, err, status = Run.cmd(BIN_FILE_ROOT, cmd, inputList, @testCase.timeLimit)
      checkHeapUsed(err)
    rescue MemFlow => memFlow
      @result.mem(caseName, memFlow.message)
      return
    rescue TimeoutError => timeoutErr
      @result.time(caseName, "time out for expect time: #{@testCase.timeLimit}")
      raise timeoutErr
    rescue => ex
      raise RunError.new(ex.message)
    end

    unless out == output
      @result.function(caseName, "expect: #{output}, actul: #{out}")
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
    rescue TimeoutError => timeoutErr
      return
    rescue => ex
      raise SystemError.new(ex.message)
    end
  end

  private :compile
  private :runTest
  private :functionTest

end