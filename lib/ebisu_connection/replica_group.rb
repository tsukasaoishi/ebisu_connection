require "ebisu_connection/replica"
require "ebisu_connection/greatest_common_divisor"

module EbisuConnection
  class ReplicaGroup
    class AllReplicaHasGoneError < StandardError; end

    def initialize(replica_conf, replica_group)
      @replicas = replica_conf.map do |conf|
        Replica.new(conf, replica_group)
      end

      recalc_roulette
    end

    def sample
      raise AllReplicaHasGoneError if @replicas.empty?
      @replicas[@roulette.sample]
    end

    def recovery_connection?
      dead_replicas = @replicas.select{|s| !s.active? }
      return false if dead_replicas.empty?

      dead_replicas.each do |s|
        s.disconnect!
        @replicas.delete(s)
      end

      raise AllReplicaHasGoneError if @replicas.empty?

      recalc_roulette
      true
    end

    def all_disconnect!
      @reserve_release = nil
      @replicas.each {|s| s.disconnect!}
    end

    def reserve_release_connection!
      @reserve_release = true
    end

    def reserved_release?
      !!@reserve_release
    end

    private

    def recalc_roulette
      weight_list = @replicas.map {|s| s.weight }

      @roulette = []
      gcd = GreatestCommonDivisor.calc(weight_list)
      weight_list.each_with_index do |w, index|
        weight = w / gcd
        @roulette.concat([index] * weight)
      end
    end
  end
end
