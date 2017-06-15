PASS = "pass"
FAIL = "fail"
TEST_FILE_ERROR = "test file error"

class TestResult

  def initialize(compileId, problemId)
    @compileId = compileId
    @problemId = problemId
    @resut = Hash.new(Hash.new)
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
    add(testCaseName, result, "FunctionTest")
  end

  def mem(testCaseName, result)
    add(testCaseName, result, "MemTest")
  end

  def time(testCaseName, result)
    add(testCaseName, result, "TimeTest")
  end

  def dump()
    @resut.each do |key, value|
      Log.dbg("===============================")
      Log.dbg("test case #{key} run result: ")
      value.each do |sKey, sValue|
        Log.dbg("#{sKey} => #{sValue}")
      end
    end
    Log.dbg("===============================")
  end

end