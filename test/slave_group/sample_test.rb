require "test_helper"

class SampleTest < Minitest::Test
  def setup
    @sg = EbisuConnection::SlaveGroup
  end

  test "raise exception if slaves empty" do
    inst = @sg.new([], "slave")
    assert_raises(EbisuConnection::SlaveGroup::AllSlavesHasGoneError) do
      inst.sample
    end
  end

  test "return slve instance object" do
    inst = @sg.new(["h"], "slave")
    assert_kind_of EbisuConnection::Slave, inst.sample
  end
end
