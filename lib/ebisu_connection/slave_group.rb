require 'ebisu_connection/greatest_common_divisor'
require 'ebisu_connection/slave'

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
