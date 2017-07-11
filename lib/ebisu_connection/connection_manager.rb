require "concurrent"
require "ebisu_connection/replica"
require "ebisu_connection/greatest_common_divisor"

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    class AllReplicaHasGoneError < StandardError; end

    def initialize(spec_name = nil)
      super

      @replicas = Concurrent::Array.new

      replica_conf.each do |conf|
        @replicas << Replica.new(conf, spec_name)
      end

      recalc_roulette
    end

    def replica_connection
      raise AllReplicaHasGoneError if @replicas.empty?
      @replicas[@roulette.sample].connection
    end

    def put_aside!
      @replicas.each do |pool|
        pool.release_connection if pool.active_connection? && !pool.connection.transaction_open?
      end
    end

    def clear_all_connections!
      @replicas.each do |pool|
        pool.disconnect!
      end
    end

    def recovery?
      dead_replicas = @replicas.select do |pool|
        c = pool.connection rescue nil
        !c || !c.active?
      end
      return false if dead_replicas.empty?

      dead_replicas.each do |pool|
        pool.disconnect!
        @replicas.delete(pool)
      end

      raise AllReplicaHasGoneError if @replicas.empty?

      recalc_roulette
      true
    end

    private

    def recalc_roulette
      weight_list = @replicas.map {|pool| pool.weight }

      @roulette = []
      gcd = GreatestCommonDivisor.calc(weight_list)
      weight_list.each_with_index do |w, index|
        weight = w / gcd
        @roulette.concat([index] * weight)
      end
    end

    def replica_conf
      ConfFile.replica_conf(spec_name)
    end
  end
end
