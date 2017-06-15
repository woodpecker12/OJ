require_relative 'module/file_manager'
require_relative 'module/json_parser'
require_relative 'exception/exception'
require_relative 'module/http'
require_relative 'module/run'
require_relative 'test/c_test'
require_relative 'test/test_result'
require_relative 'test/test_case'

class Task
  include FileManager
  include JsonParser
  include Http
  include Run

  def initialize(jsonPath)
    task = JsonParser.parse(jsonPath)

    @id = task["id"]
    @userId = task["userId"]
    @createTime = task["createTime"]
    @language = task["language"]
    @problemId = task["problemId"]
    @timeLimit = task["timeLimit"]
    @memLimit = task["memoryLimit"]
    @testCaseUrl = task["testCaseUrl"]
    @codeSource = task["code"]

    @codeFile = @id + ".c"
    FileManager.write("code/" + @codeFile, task["code"])

  end

  def run()
    begin
      result = TestResult.new(@id, @problemId)
      testCase = TestCase.new(@id, @testCaseUrl, @memLimit, @timeLimit)

      CTest.new(@id, @codeSource, testCase, result).run

      result.dump
      return result
    rescue CompileError => compileErr
      return compileErr.errCode
    rescue RunError => runErr
      return runErr.errCode
    rescue SystemError => sysErr
      return sysErr.errCode
    end
  end

end