module EbisuConnection
  class GreatestCommonDivisor
    class << self
      def calc(set)
        self.new(set).calc
      end
    end

    def initialize(set)
      @set = set.sort.uniq
    end

    def calc
      n = @set.shift
      return n if n == 1 || @set.empty?

      while !@set.empty?
        m = @set.shift
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
  end
end
