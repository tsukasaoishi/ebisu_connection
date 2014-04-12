require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'

module EbisuConnection
  class Slave
    attr_reader :hostname, :weight

    def initialize(conf, spec)
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

      @spec = spec.merge(modify_spec)
      @weight = (weight || 1).to_i
    end

    def connection
      @connection ||= ActiveRecord::Base.send("mysql2_connection", @spec)
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
