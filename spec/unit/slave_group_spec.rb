require 'spec_helper'

describe EbisuConnection::SlaveGroup do
  before(:all) do
    @sg = EbisuConnection::SlaveGroup
    @spec = {
      "adapter" => "mysql2",
      "database" => "ebisu_connection_test",
      "username" => "root"
    }
  end

  context "#sample" do
    it "raise exception if slaves empty" do
      inst = @sg.new([], {})
      expect{
        inst.sample
      }.to raise_error(EbisuConnection::SlaveGroup::AllSlavesHasGoneError)
    end

    it "return slve instance object" do
      inst = @sg.new(["h"], {})
      expect(inst.sample).to be_a(EbisuConnection::Slave)
    end
  end

  context "#remove_connection" do
    it "raise exception AllSlavesHasGoneError when slaves size is one" do
      inst = @sg.new(["localhost"], @spec)
      c = inst.sample.connection
      expect {
        inst.remove_connection(c)
      }.to raise_error(EbisuConnection::SlaveGroup::AllSlavesHasGoneError)
    end
  end
end
