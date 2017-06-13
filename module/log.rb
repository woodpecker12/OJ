$DEBUG_REDIRECT = false

module Log

  def Log.dbg(str)
    if $DEBUG_REDIRECT == false
      puts str
    else
      # redirect log
    end
  end
end