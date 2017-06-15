require_relative 'base/environment'
require_relative 'task'

Environment.init

Task.new("commit.json").run

