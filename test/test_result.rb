TEST_FILE_ERROR = "test file error"

class TestResult

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
  end

  attr_writer :errCode
  attr_reader :endTime

  private :add

end