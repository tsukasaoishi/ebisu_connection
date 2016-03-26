require "test_helper"

class SampleTest < Minitest::Test
  def setup
    @sg = EbisuConnection::SlaveGroup
  end

  test "raise exception AllSlavesHasGoneError when slaves size is one" do
    inst = @sg.new(["localhost"], "slave")
    c = inst.sample.connection
    c.disconnect!
    assert_raises(EbisuConnection::SlaveGroup::AllSlavesHasGoneError) do
      inst.recovery_connection?
    end
  end
end
