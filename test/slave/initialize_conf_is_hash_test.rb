require "test_helper"

class InitializeConfIsHashTest < Minitest::Test
  test "hostname only" do
    s = EbisuConnection::Slave.new({:host => "host_1"}, "slave")
    assert_equal "host_1", s.hostname
    assert_equal 1, s.weight
  end

  test "hostname and weight" do
    s = EbisuConnection::Slave.new({:host => "host_1", :weight => 10}, "slave")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end

  test "hostname, weight and port" do
    s = EbisuConnection::Slave.new({:host => "host_1", :weight => 10, :port => 1975}, "slave")
    assert_equal "host_1", s.hostname
    assert_equal 10, s.weight
  end
end
