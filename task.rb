require 'rubygems'
require 'json'
require 'pp'

require_relative 'module/file_manager'
require_relative 'module/json_parser'
require_relative 'module/c_generater'
require_relative 'exception/compile_error'

class Task
  include FileManager
  include JsonParser
  include CGenerater

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

    CGenerater.run(@codeFile)

    return ALL_SUCC
  end

end