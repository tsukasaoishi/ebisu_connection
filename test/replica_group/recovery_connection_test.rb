require "test_helper"

class RecoveryConnectionTest < Minitest::Test
  def setup
    @sg = EbisuConnection::ReplicaGroup
  end

  test "raise exception AllReplicaHasGoneError when replicas size is one" do
    inst = @sg.new(["localhost"], "replica")
    c = inst.sample.connection
    c.disconnect!
    assert_raises(EbisuConnection::ReplicaGroup::AllReplicaHasGoneError) do
      inst.recovery_connection?
    end
  end
end
