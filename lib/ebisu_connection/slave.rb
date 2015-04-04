require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'

module EbisuConnection
  class Slave
    attr_reader :hostname, :weight

    def initialize(conf, slave_group)
      case conf
      when String
        host, weight = conf.split(/\s*,\s*/)
        @hostname, port = host.split(/\s*:\s*/)
      when Hash
        conf.stringify_keys!
        @hostname = conf["host"]
        weight = conf["weight"]
        port = conf["port"]
      else
        raise ArgumentError, "slaves config is invalid"
      end

      modify_spec = {"host" => @hostname}
      modify_spec["port"] = port.to_i if port.present?

      @connection_factory = FreshConnection::ConnectionFactory.new(slave_group, modify_spec)
      @weight = (weight || 1).to_i
    end

    def connection
      @connection ||= @connection_factory.new_connection
    end

    def disconnect!
      if @connection
        @connection.disconnect!
        @connection = nil
      end
    rescue
    end
  end
end
