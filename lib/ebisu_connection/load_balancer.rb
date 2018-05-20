require "ebisu_connection/greatest_common_divisor"

module EbisuConnection
  class LoadBalancer
    def initialize(replicas)
      @replicas = replicas
    end

    def replica
      @replicas[roulette.sample]
    end

    private

    def roulette
      @roulette ||= calc_roulette
    end

    def calc_roulette
      set = []
      weight_list = @replicas.map(&:weight)
      gcd = GreatestCommonDivisor.calc(weight_list)

      weight_list.each_with_index do |w, index|
        weight = w / gcd
        set.concat([index] * weight)
      end

      set
    end
  end
end
