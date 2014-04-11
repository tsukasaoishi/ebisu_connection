require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'

module EbisuConnection
  class Slaves
    class AllSlavesHasGoneError < StandardError; end

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

    def initialize(slaves_conf, spec)
      @slaves = slaves_conf.map do |conf|
        Slave.new(conf, spec)
      end

      recalc_roulette
    end

    def sample
      raise AllSlavesHasGoneError if @slaves.blank?
      @slaves[@roulette.sample]
    end

    def remove_connection(connection)
      return unless s = @slaves.detect{|s| s.connection == connection}
      s.disconnect! rescue nil
      @slaves.delete(s)
      raise AllSlavesHasGoneError if @slaves.blank?
      recalc_roulette
      nil
    end

    def all_disconnect!
      @reserve_release = nil
      @slaves.each {|s| s.disconnect!}
    end

    def reserve_release_connection!
      @reserve_release = true
    end

    def reserved_release?
      !!@reserve_release
    end

    private

    def recalc_roulette
      weight_list = @slaves.map {|s| s.weight }

      @roulette = []
      gcd = GreatestCommonDivisor.calc(weight_list)
      weight_list.each_with_index do |w, index|
        weight = w / gcd
        @roulette.concat([index] * weight)
      end
    end
  end
end
