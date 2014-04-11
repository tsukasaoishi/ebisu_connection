require 'spec_helper'

describe EbisuConnection::GreatestCommonDivisor do
  before(:all) do
    @g = EbisuConnection::GreatestCommonDivisor
  end

  context ".calc" do
    it "return nil if set is empty" do
      expect(@g.calc([])).to be_nil
    end
  end
end
