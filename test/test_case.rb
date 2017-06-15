require_relative '../module/http'
require_relative '../module/run'
require_relative '../module/file_manager'
require_relative '../base/environment'
require_relative '../module/log'
require_relative '../exception/exception'

class TestCase
  include Http
  include Run
  include FileManager
  include Log


  def initialize(id, testCaseUrl, memLimit, timeLimit)
    @testId = id
    @testCaseUrl = testCaseUrl
    @memLimit = memLimit
    @timeLimit = timeLimit
    @testCaseList = Array.new

    downloadTestCase()
  end

  def downloadTestCase()
    saveFileName = "#{@testId}.zip"
    saveFilePath = TEST_CASE_ROOT + saveFileName

    begin
      Log.dbg("downloading test case...")

      Http.getFile(@testCaseUrl, saveFilePath)
      Run.cmd(TEST_CASE_ROOT, "unzip -o -d #{@testId}/ #{saveFileName}")

      FileManager.fileList(TEST_CASE_ROOT + @testId).each do |file|
        testCaseName = File.basename(file, ".*")
        @testCaseList << testCaseName unless @testCaseList.include?(testCaseName)
      end

      Log.dbg("downloading test case done!!!")
    rescue => ex
      Log.dbg("download test case error!!!")
      raise SystemError.new(ex.message)
    end
  end

  def fetchTestCase()
    invalidTestCase = Array.new
    validTestInOut = Hash.new(Array.new)

    begin
      @testCaseList.each do |caseName|
        testIn = "#{TEST_CASE_ROOT}#{@testId}/#{caseName}.in"
        testOut = "#{TEST_CASE_ROOT}#{@testId}/#{caseName}.out"

        unless File.exist?(testIn) and File.exist?(testOut) then
          invalidTestCase << caseName
          next
        end

        input = File.open(testIn).readline
        output = File.open(testOut).readline
        validTestInOut.store(caseName, [input, output])
      end

      return validTestInOut, invalidTestCase
    rescue => ex
      raise SystemError.new(ex.mesage)
    end
  end

  attr_reader :memLimit
  attr_reader :timeLimit

end