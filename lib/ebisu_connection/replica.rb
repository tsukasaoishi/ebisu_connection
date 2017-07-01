require 'fresh_connection/connection_factory'

module EbisuConnection
  class Replica
    attr_reader :hostname, :weight

    def initialize(conf, replica_group)
      case conf
      when String
        host, weight = conf.split(/\s*,\s*/)
        @hostname, port = host.split(/\s*:\s*/)
      when Hash
        @hostname = conf["host"] || conf[:host]
        weight = conf["weight"] || conf[:weight]
        port = conf["port"] || conf[:port]
      else
        raise ArgumentError, "replica config is invalid"
      end

      spec = modify_spec(port)
      @connection_factory = FreshConnection::ConnectionFactory.new(replica_group, spec)
      @weight = (weight || 1).to_i
    end

    def connection
      @connection ||= @connection_factory.new_connection
    end

    def active?
      connection.active?
    end

    def disconnect!
      if @connection
        @connection.disconnect!
        @connection = nil
      end
    rescue
    end

    def modify_spec(port)
      modify_spec = {"host" => @hostname}
      return modify_spec unless port
      modify_spec["port"] = port.to_i if port.is_a?(Integer) || !port.empty?
      modify_spec
    end
  end
end
