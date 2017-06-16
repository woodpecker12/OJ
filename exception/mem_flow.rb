class MemFlow < RuntimeError
  def initialize(message)
    @message = message
    @errCode = MEM_FLOW
  end

  attr_reader :message
  attr_reader :errCode
end