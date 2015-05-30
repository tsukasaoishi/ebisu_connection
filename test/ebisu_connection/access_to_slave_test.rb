require "test_helper"

class AccessToSlaveTest < Minitest::Test
  test "select from User is to access to slave" do
    assert_includes User.first.name, "slave"
  end
end
