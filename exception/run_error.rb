class RunError < RuntimeError

  def initialize(message)
    @message = message
    @errCode = RUN_ERROR
  end

  attr_reader :message
  attr_reader :errCode
end