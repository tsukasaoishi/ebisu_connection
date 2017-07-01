require "concurrent"
require "ebisu_connection/replica_group"

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    def initialize(replica_group = "replica")
      super
      @replicas = Concurrent::Map.new
    end

    def replica_connection
      replicas.sample.connection
    end

    def put_aside!
      check_own_connection
    end

    def clear_all_connections!
      @replicas.each_value do |s|
        s.all_disconnect!
      end

      @replicas.clear
    end

    def recovery?
      replicas.recovery_connection?
    end

    private

    def check_own_connection
      s = @replicas[current_thread_id]
      return if !s || !s.reserved_release?

      s.all_disconnect!
      @replicas.delete(current_thread_id)
    end

    def replicas
      @replicas.fetch_or_store(current_thread_id) do |_|
        get_replicas
      end
    end

    def get_replicas
      ReplicaGroup.new(replica_conf, replica_group)
    end

    def replica_conf
      ConfFile.replica_conf(replica_group)
    end

    def current_thread_id
      Thread.current.object_id
    end
  end
end
