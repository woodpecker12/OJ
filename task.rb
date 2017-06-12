require 'rubygems'
require 'json'
require 'pp'

require_relative 'module/file_manager'
require_relative 'module/json_parser'
require_relative 'module/c_compile'

class Task
  include FileManager
  include JsonParser
  include CCompile

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

  def compile()
    puts CCompile.run(@codeFile)
  end

end