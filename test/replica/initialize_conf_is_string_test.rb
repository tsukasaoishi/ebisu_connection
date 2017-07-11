require "test_helper"
require "ebisu_connection/replica"

class InitializeConfIsStringTest < Minitest::Test
  test "hostname only" do
    s = EbisuConnection::Replica.new("host_1", "replica")
    assert_equal "host_1", s.hostname
    assert_equal 1, s.weight
  end

  test "hostname and weight" do
    s = EbisuConnection::Replica.new("host_1, 10", "replica")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end

  test "hostname, weight and port" do
    s = EbisuConnection::Replica.new("host_1:1975, 10", "replica")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end
end
