require_relative 'module/file_manager'
require_relative 'module/json_parser'
require_relative 'module/c_generater'
require_relative 'exception/compile_error'
require_relative 'module/http'
require_relative 'module/run'

class Task
  include FileManager
  include JsonParser
  include CGenerater
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
    @memoryLimit = task["memoryLimit"]
    @testCaseUrl = task["testCaseUrl"]

    @codeFile = @id + ".c"
    FileManager.write("code/" + @codeFile, task["code"])

  end

  def run()
    begin
      CGenerater.compile(@codeFile)
    rescue CompileError => compileErr
      return compileErr.errCode
    end

    CGenerater.run(@codeFile) if fetchTestFiles(@testCaseUrl)

    return ALL_SUCC
  end

  def fetchTestFiles(testFileUrl)

    @testCaseList = []

    begin
      Log.dbg("fetching test case...")

      Http.getFile(testFileUrl, "test/#{@id}.zip")
      Run.cmd("test/", "unzip -o -d #{@id}/ #{@id}.zip")

      FileManager.fileList("test/#{@id}").each do |item|
        baseName = File.basename(item, ".*")
        @testCaseList << baseName if !@testCaseList.include?(baseName)
      end

      Log.dbg("fetching test case done!!!")
    rescue
      # Dir.delete("test/#{@id}") if Dir.exist?("test/#{@id}")
      Log.dbg("fetch test case error!!!")
      return false
    end
    return true
  end

end