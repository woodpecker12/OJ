require_relative 'base/environment'
require_relative 'task'

Environment.init

result = Task.new(ARGV[0]).run

result.dump