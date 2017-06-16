TEST_FILE_ERROR = "test file error"

require_relative '../module/file_manager'

require 'rubygems'
require 'json'

class TestResult
  include FileManager

  @@timeFormat = "%Y-%m-%d %H:%M:%S"
  def initialize(id, problemId)
    @id = id
    @problemId = problemId
    @resut = Hash.new(Hash.new)
    @errCode = PASS
    @startTime = Time.now.strftime(@@timeFormat)
  end

  def cppCheck(result)
    @cppCheckResult = result
  end

  def cppCheckScore(score)
    @cppCheckScore = score
  end

  def recordEndTime
    @endTime = Time.now.strftime(@@timeFormat)
  end

  def updateErrCode(errCode)
    @errCode = errCode if @errCode == PASS
  end

  def add(testCaseName, result, sKey)
    if @resut.has_key?(testCaseName)
      @resut[testCaseName][sKey] = result
      return
    end

    testItemResut = Hash.new
    testItemResut.store(sKey, result)
    @resut.store(testCaseName, testItemResut)
  end

  def function(testCaseName, result)
    updateErrCode(RESULT_ERROR)
    add(testCaseName, result, "FunctionTest")
  end

  def mem(testCaseName, result)
    updateErrCode(MEM_FLOW)
    add(testCaseName, result, "MemTest")
  end

  def time(testCaseName, result)
    updateErrCode(RUN_TIME_OUT)
    add(testCaseName, result, "TimeTest")
  end

  def dump()
    Log.dbg("===============================")
    Log.dbg("id        : #{@id}")
    Log.dbg("problemId : #{@problemId}")
    Log.dbg("start time: #{@startTime}")
    Log.dbg("end time  : #{@endTime}")
    Log.dbg("error code: #{toStr(@errCode)}[#{@errCode}]")
    @resut.each do |key, value|
      Log.dbg("===============================")
      Log.dbg("test case #{key} run result: ")
      value.each do |sKey, sValue|
        Log.dbg("#{sKey} => #{sValue}")
      end
    end
    Log.dbg("===============================")

    baseReslt = Hash.new
    baseReslt.store("id", @id)
    baseReslt.store("problemId", @problemId)
    baseReslt.store("startTime", @startTime)
    baseReslt.store("endTime", @endTime)
    baseReslt.store("errCode", @errCode)

    # puts baseReslt.to_json
    # puts @resut.to_json

    FileManager.write("log/#{@id}.json", baseReslt.to_json)
  end

  attr_writer :errCode
  attr_reader :endTime

  private :add

end