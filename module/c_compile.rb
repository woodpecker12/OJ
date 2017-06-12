require_relative 'run'

module CCompile
  include Run

  @@defaulBinPath = "target/"

  def CCompile.run(codeSource)
    binName = File.basename(codeSource, ".*")
    Run.cmd(@@defaulBinPath, "gcc -o #{binName} ../code/#{codeSource}")
    Run.cmd(@@defaulBinPath, "./#{binName}")
  end

end