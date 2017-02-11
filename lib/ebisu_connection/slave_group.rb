require "ebisu_connection/slave"
require "ebisu_connection/greatest_common_divisor"

module EbisuConnection
  class SlaveGroup
    class AllSlavesHasGoneError < StandardError; end

    def initialize(slaves_conf, slave_group)
      @slaves = slaves_conf.map do |conf|
        Slave.new(conf, slave_group)
      end

      recalc_roulette
    end

    def sample
      raise AllSlavesHasGoneError if @slaves.empty?
      @slaves[@roulette.sample]
    end

    def recovery_connection?
      dead_slaves = @slaves.select{|s| !s.active? }
      return false if dead_slaves.empty?

      dead_slaves.each do |s|
        s.disconnect!
        @slaves.delete(s)
      end

      raise AllSlavesHasGoneError if @slaves.empty?

      recalc_roulette
      true
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
