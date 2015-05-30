require "test_helper"

class SampleTest < Minitest::Test
  def setup
    @sg = EbisuConnection::SlaveGroup
  end

  test "raise exception AllSlavesHasGoneError when slaves size is one" do
    inst = @sg.new(["localhost"], "slave")
    c = inst.sample.connection
    assert_raises(EbisuConnection::SlaveGroup::AllSlavesHasGoneError) do
      inst.remove_connection(c)
    end
  end
end
