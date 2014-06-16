require 'spec_helper'

describe EbisuConnection do
  context "access to slave" do
    it "select from User is to access to slave" do
      expect(User.first.name).to be_include("slave")
    end
  end

  context "access to master" do
    it "specify readonly(false)" do
      expect(User.readonly(false).first.name).to be_include("master")
    end
  end
end
