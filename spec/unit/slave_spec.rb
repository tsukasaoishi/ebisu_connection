require 'spec_helper'

describe EbisuConnection::Slave do
  context "initialize(conf is String)" do
    it "hostname only" do
      s = EbisuConnection::Slave.new("host_1", "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(1)
    end

    it "hostname and weight" do
      s = EbisuConnection::Slave.new("host_1, 10", "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end

    it "hostname, weight and port" do
      s = EbisuConnection::Slave.new("host_1:1975, 10", "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end
  end

  context "initialize(conf is Hash)" do
    it "hostname only" do
      s = EbisuConnection::Slave.new({:host => "host_1"}, "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(1)
    end

    it "hostname and weight" do
      s = EbisuConnection::Slave.new({:host => "host_1", :weight => 10}, "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end

    it "hostname, weight and port" do
      s = EbisuConnection::Slave.new({:host => "host_1", :weight => 10, :port => 1975}, "slave")
      expect(s.hostname).to eq("host_1")
      expect(s.weight).to eq(10)
    end
  end

  context "#connection" do
    it "return Mysql2Adapter object" do
      s = EbisuConnection::Slave.new("localhost", "slave")
      expect(s.connection).to be_a(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    end
  end
end
