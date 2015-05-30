require "test_helper"

class ConnectionTest < Minitest::Test
  test "return Mysql2Adapter object" do
    s = EbisuConnection::Slave.new("localhost", "slave")
    assert_kind_of ActiveRecord::ConnectionAdapters::Mysql2Adapter, s.connection
  end
end
