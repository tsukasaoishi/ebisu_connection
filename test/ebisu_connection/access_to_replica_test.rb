require "test_helper"

class AccessToReplicaTest < Minitest::Test
  test "select from User is to access to replica" do
    assert_includes User.first.name, "replica"
  end
end
