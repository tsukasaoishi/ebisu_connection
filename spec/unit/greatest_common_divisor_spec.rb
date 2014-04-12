require 'spec_helper'

describe EbisuConnection::GreatestCommonDivisor do
  before(:all) do
    @g = EbisuConnection::GreatestCommonDivisor
  end

  context ".calc" do
    it "return nil if set is empty" do
      expect(@g.calc([])).to be_nil
    end

    it "return first element if set has one element" do
      expect(@g.calc([1])).to eq(1)
    end

    it "return first element if set has elements that is all same" do
      set = [1] * 100
      expect(@g.calc(set)).to eq(1)
    end

    it "return 1 if set includes 1 in elements" do
      set = (1..100).to_a
      expect(@g.calc(set)).to eq(1)
    end

    it "return gcd" do
      expect(@g.calc([2,4])).to eq(2)
      expect(@g.calc([2,4,6])).to eq(2)
      expect(@g.calc([4,6])).to eq(2)
      expect(@g.calc([3,4,6])).to eq(1)
      expect(@g.calc([3,6])).to eq(3)
      expect(@g.calc([10,10,2])).to eq(2)
      expect(@g.calc([10,10,2,10,5])).to eq(1)
      expect(@g.calc([10,10,10,5])).to eq(5)
    end
  end
end
