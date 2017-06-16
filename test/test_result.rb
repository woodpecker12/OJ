TEST_FILE_ERROR = "test file error"

require_relative '../module/file_manager'

class TestResult
  include FileManager

  def initialize(id, problemId)
    @id = id
    @problemId = problemId
    @resut = Hash.new(Hash.new)
    @errCode = PASS
    @startTime = Time.now

  end

  def recordEndTime
    @endTime = Time.now
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
    str = ""
    str << Log.dbg("===============================")
    str << Log.dbg("id        : #{@id}")
    str << Log.dbg("problemId : #{@problemId}")
    str << Log.dbg("start time: #{@startTime}")
    str << Log.dbg("end time  : #{@endTime}")
    str << Log.dbg("error code: #{toStr(@errCode)}[#{@errCode}]")
    @resut.each do |key, value|
      str << Log.dbg("===============================")
      str << Log.dbg("test case #{key} run result: ")
      value.each do |sKey, sValue|
        str << Log.dbg("#{sKey} => #{sValue}")
      end
    end
    str << Log.dbg("===============================")

    FileManager.write("log/#{@id}.result", str)
  end

  attr_writer :errCode
  attr_reader :endTime

  private :add

end