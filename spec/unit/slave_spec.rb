require 'spec_helper'

describe EbisuConnection::Slave do
  context "initialize(conf is String)" do
    it "hostname only" do
      s = EbisuConnection::Slave.new("host_1", {})
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(1)
    end

    it "hostname and weight" do
      s = EbisuConnection::Slave.new("host_1, 10", {})
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end

    it "hostname, weight and port" do
      s = EbisuConnection::Slave.new("host_1:1975, 10", {})
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end
  end
end
