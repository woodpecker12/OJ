require_relative 'module/file_manager'
require_relative 'module/json_parser'
require_relative 'exception/compile_error'
require_relative 'module/http'
require_relative 'module/run'
require_relative 'c_generater'
require_relative 'test_result'

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

    @codeFile = @id + ".c"
    FileManager.write("code/" + @codeFile, task["code"])

  end

  def run()
    result = TestResult.new(@id, @problemId)

    begin
      fetchTestFiles(@testCaseUrl)
      cpp = CGenerater.new(@codeFile, @testCaseList, @timeLimit, @memLimit, result)
      cpp.compile
      cpp.runTest
    rescue CompileError => compileErr
      return compileErr.errCode
    end
  end

  def fetchTestFiles(testFileUrl)

    @testCaseList = []

    begin
      Log.dbg("fetching test case...")
      zipFileName = "#{@id}.zip"
      zipFilePath = "test/#{zipFileName}"

      Http.getFile(testFileUrl, zipFilePath)
      Run.cmd("test/", "unzip -o -d #{@id}/ #{zipFileName}")

      FileManager.fileList("test/#{@id}").each do |item|
        baseName = File.basename(item, ".*")
        @testCaseList << baseName unless @testCaseList.include?(baseName)
      end

      FileManager.delete(zipFilePath) if Dir.exist?(zipFilePath)
      Log.dbg("fetching test case done!!!")
    rescue
      # Dir.delete("test/#{@id}") if Dir.exist?("test/#{@id}")
      Log.dbg("fetch test case error!!!")
      return false
    end
    return true
  end

end