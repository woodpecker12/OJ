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
    @timeLimit = task["timeLimit"] / 1000 == 0 ? 1 : task["timeLimit"] / 1000
    @memLimit = task["memoryLimit"] * 1024
    @testCaseUrl = task["testCaseUrl"]
    @codeSource = task["code"]

  end

  def run()
    result = TestResult.new(@id, @problemId)
    
    begin
      testCase = TestCase.new(@id, @testCaseUrl, @memLimit, @timeLimit)
      CTest.new(@id, @codeSource, testCase, result).run
    rescue => ex
      result.errCode = ex.errCode
    ensure
      result.recordEndTime
      return result
    end
  end

end