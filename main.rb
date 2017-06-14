require_relative 'task'

Dir.mkdir("target") unless Dir.exist?("target")
Dir.mkdir("code") unless Dir.exist?("code")
Dir.mkdir("log") unless Dir.exist?("log")

Task.new("commit.json").run

