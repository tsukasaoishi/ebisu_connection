require "test_helper"

class SampleTest < Minitest::Test
  def setup
    @sg = EbisuConnection::ReplicaGroup
  end

  test "raise exception if replicas empty" do
    inst = @sg.new([], "replica")
    assert_raises(EbisuConnection::ReplicaGroup::AllReplicaHasGoneError) do
      inst.sample
    end
  end

  test "return slve instance object" do
    inst = @sg.new(["h"], "replica")
    assert_kind_of EbisuConnection::Replica, inst.sample
  end
end
