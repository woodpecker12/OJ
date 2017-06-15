class CompileError < StandardError

  def initialize(message)
    @message = message
    @errCode = COMPILE_ERROR
  end

  attr_reader :message
  attr_reader :errCode

end