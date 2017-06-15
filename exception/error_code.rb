PASS = 0
RUN_ERROR = 1
RUN_TIME_OUT = 2
MEM_FLOW = 3
COMPILE_ERROR = 4
CODE_FORMAT_ERROR = 5
RESULT_ERROR = 6
SYSTEM_ERROR = 7

def toStr(code)
  case code
    when 0
      return "PASS"
    when 1
      return "RUN_ERROR"
    when 2
      return "RUN_TIME_OUT"
    when 3
      return "MEM_FLOW"
    when 4
      return "COMPILE_ERROR"
    when 5
      return "CODE_FORMAT_ERROR"
    when 6
      return "RESULT_ERROR"
    when 7
      return "SYSTEM_ERROR"
  end
end