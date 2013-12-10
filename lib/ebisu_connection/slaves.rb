module EbisuConnection
  class Slaves
    class Slave
      attr_reader :hostname. :weight
      def initialize(conf, spec)
        @hostname, weight = conf.split(/\s*,\s*/)
        @weight = (weight || 1).to_i
        @spec = spec.merge(:hostname => hostname)
      end

      def connection
        @connection ||= ActiveRecord::Base.send("#{@spec["adapter"]}_connection", @spec)
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
      weight_list = []
      @slaves = slaves_conf.map do |conf|
        s = Slave.new(conf, spec)
        weight_list << s.weight
        s
      end

      @roulette = []
      gcd = get_gcd(weight_list)
      weight_list.each_with_index do |w, index|
        weight = w / gcd
        @roulette.concat([index] * weight)
      end
    end

    def sample
      @slaves[@roulette.sample]
    end

    def all_disconnect!
      @slaves.each {|s| s.disconnect!}
    end

    private

    def get_gcd(list)
      list = list.sort.uniq
      n = list.shift
      return n if n == 1 || list.empty?

      while !list.empty?
        m = list.shift
        n = gcd_euclid(m, n)
      end
      n
    end

    def gcd_euclid(m, n)
      m, n = n, m if m < n
      while n != 0
        work = m % n
        m = n
        n = work
      end
      m
    end
  end
end
