require_relative '../module/run'

class CppCheck
   include Run

   def  run(dir, sourceFile)
      out, err, status = Run.cmd(dir, "cppcheck --enable=all #{sourceFile}")
      log = out + err
      @all = {:error=> 0, :warning=> 0, :portablity=> 0, :performance=>0, :style => 0}
      list = log.each_line {|line|
        @all.keys.each{|key| @all[key]+=1 if line=~/(#{key[0..-1]})/}
      }
      return log
   end
   
   def score 
       scores = {:error=> 5, :warning=> 4, :portablity=> 3, :performance=>2, :style => 1}
       minus = scores.map {|var| @all[var[0]] * var[1]}
       return minus.inject(100) { |result, element| result - element }
   end
end