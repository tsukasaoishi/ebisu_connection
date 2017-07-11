require 'fresh_connection/connection_specification'

module EbisuConnection
  class Replica
    attr_reader :hostname, :weight

    def initialize(conf, spec_name)
      case conf
      when String
        host, weight = conf.split(/\s*,\s*/)
        @hostname, @port = host.split(/\s*:\s*/)
      when Hash
        @hostname = conf["host"] || conf[:host]
        weight = conf["weight"] || conf[:weight]
        @port = conf["port"] || conf[:port]
      else
        raise ArgumentError, "replica config is invalid"
      end

      spec = FreshConnection::ConnectionSpecification.new(
        spec_name, modify_spec: modify_spec
      ).spec

      @pool = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
      @weight = (weight || 1).to_i
    end

    def connection
      @pool.connection
    end

    def active_connection?
      @pool.active_connection?
    end

    def release_connection
      @pool.release_connection
    end

    def disconnect!
      @pool.disconnect!
    end

    private

    def modify_spec
      modify_spec = {"host" => @hostname}
      return modify_spec if !defined?(@port) || @port.nil?
      return modify_spec if @port.respond_to?(:empty?) && @port.empty?

      modify_spec["port"] = @port.to_i
      modify_spec
    end
  end
end
