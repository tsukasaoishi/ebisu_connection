require "test_helper"

class InitializeConfIsStringTest < Minitest::Test
  test "hostname only" do
    s = EbisuConnection::Slave.new("host_1", "slave")
    assert_equal "host_1", s.hostname
    assert_equal 1, s.weight
  end

  test "hostname and weight" do
    s = EbisuConnection::Slave.new("host_1, 10", "slave")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end

  test "hostname, weight and port" do
    s = EbisuConnection::Slave.new("host_1:1975, 10", "slave")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end
end
