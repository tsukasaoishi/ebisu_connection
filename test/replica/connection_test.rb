require "test_helper"

class ConnectionTest < Minitest::Test
  test "return Mysql2Adapter object" do
    s = EbisuConnection::Replica.new("localhost", "replica")
    case ENV['DB_ADAPTER']
    when 'mysql2'
      assert_kind_of ActiveRecord::ConnectionAdapters::Mysql2Adapter, s.connection
    when 'postgresql'
      assert_kind_of ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, s.connection
    end
  end
end
