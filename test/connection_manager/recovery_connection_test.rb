require "test_helper"
require "ebisu_connection/connection_manager"

class RecoveryConnectionTest < Minitest::Test
  def setup
    @cm = EbisuConnection::ConnectionManager
  end

  test "raise exception AllReplicaHasGoneError when replicas size is one" do
    inst = @cm.new("replica")
    r = EbisuConnection::Replica.new("localhost", "replica")
    inst.instance_variable_set("@replicas", Array(r))
    c = inst.replica_connection
    c.disconnect!
    assert_raises(EbisuConnection::ConnectionManager::AllReplicaHasGoneError) do
      inst.recovery?
    end
  end
end
