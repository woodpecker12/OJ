class SystemError < RuntimeError
  def initialize(message)
    @message = message
    @errCode = SYSTEM_ERROR
  end

  attr_reader :message
  attr_reader :errCode
end