require_relative "../module/file_manager"

SOURCE_CODE_ROOT = "code/"
LOG_ROOT = "log/"
BIN_FILE_ROOT = "target/"
TEST_CASE_ROOT = "test-case/"

module Environment
  include FileManager

  def Environment.init()
    FileManager.mkdir(SOURCE_CODE_ROOT)
    FileManager.mkdir(LOG_ROOT)
    FileManager.mkdir(BIN_FILE_ROOT)
    FileManager.mkdir(TEST_CASE_ROOT)
  end
end