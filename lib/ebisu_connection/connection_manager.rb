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
      return if check_own_connection

      ConfFile.if_modify do
        reserve_release_all_connection
        check_own_connection
      end
    end

    def clear_all_connections!
      @replicas.each_value do |s|
        s.all_disconnect!
      end

      @replicas.clear
      ConfFile.conf_clear!
    end

    def recovery?
      replicas.recovery_connection?
    end

    private

    def check_own_connection
      s = @replicas[current_thread_id]

      if s && s.reserved_release?
        s.all_disconnect!
        @replicas.delete(current_thread_id)
        true
      else
        false
      end
    end

    def reserve_release_all_connection
      @replicas.each_value do |s|
        s.reserve_release_connection!
      end
      ConfFile.conf_clear!
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
