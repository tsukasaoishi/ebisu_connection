require "test_helper"

class AccessToMasterTest < Minitest::Test
  test "specify read_master" do
    assert_includes User.read_master.first.name, "master"
  end
end

