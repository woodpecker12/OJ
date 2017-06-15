require_relative 'error_code'

class SystemError < RuntimeError
  attr_reader :message
  attr_reader :errCode

  def initialize(message)
    @message = message
    @errCode = SYSTEM_ERROR
  end
end