require "ebisu_connection/replica"
require "ebisu_connection/load_balancer"

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    class AllReplicaHasGoneError < StandardError; end

    def initialize(spec_name = nil)
      super

      @replicas = replica_conf.map do |conf|
        Replica.new(conf, spec_name)
      end
    end

    def replica_connection
      raise AllReplicaHasGoneError if @replicas.empty?
      load_balancer.replica.connection
    end

    def put_aside!
      @replicas.each(&:put_aside!)
    end

    def clear_all_connections!
      @replicas.each(&:disconnect!)
    end

    def recovery?
      dead_replicas = @replicas.select do |replica|
        c = replica.connection rescue nil
        !c || !c.active?
      end

      return false if dead_replicas.empty?

      dead_replicas.each do |replica|
        replica.disconnect!
        @replicas.delete(replica)
      end

      raise AllReplicaHasGoneError if @replicas.empty?

      @load_balancer = nil
      true
    end

    private

    def load_balancer
      @load_balancer ||= LoadBalancer.new(@replicas)
    end

    def replica_conf
      @replica_conf ||= Config.new(spec_name)
    end
  end
end
