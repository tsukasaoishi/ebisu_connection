require "test_helper"

class GreatestCommonDivisorTest < Minitest::Test
  def setup
    @g = EbisuConnection::GreatestCommonDivisor
  end

  test "return nil if set is empty" do
    assert_nil @g.calc([])
  end

  test "return first element if set has one element" do
    assert_equal 1, @g.calc([1])
  end

  test "return first element if set has elements that is all same" do
    set = [1] * 100
    assert_equal 1, @g.calc(set)
  end

  test "return 1 if set includes 1 in elements" do
    set = (1..100).to_a
    assert_equal 1, @g.calc(set)
  end

  test "return gcd" do
    assert_equal 2, @g.calc([2,4])
    assert_equal 2, @g.calc([2,4,6])
    assert_equal 2, @g.calc([4,6])
    assert_equal 1, @g.calc([3,4,6])
    assert_equal 3, @g.calc([3,6])
    assert_equal 2, @g.calc([10,10,2])
    assert_equal 1, @g.calc([10,10,2,10,5])
    assert_equal 5, @g.calc([10,10,10,5])
  end
end
