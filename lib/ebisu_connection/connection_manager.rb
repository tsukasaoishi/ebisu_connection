require 'concurrent'

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    def initialize(slave_group = "slave")
      super
      @slaves = Concurrent::Map.new
    end

    def slave_connection
      slaves.sample.connection
    end

    def put_aside!
      return if check_own_connection

      ConfFile.if_modify do
        reserve_release_all_connection
        check_own_connection
      end
    end

    def clear_all_connections!
      @slaves.each_value do |s|
        s.all_disconnect!
      end

      @slaves.clear
      ConfFile.conf_clear!
    end

    def recovery?
      slaves.recovery_connection?
    end

    private

    def check_own_connection
      s = @slaves[current_thread_id]

      if s && s.reserved_release?
        s.all_disconnect!
        @slaves.delete(current_thread_id)
        true
      else
        false
      end
    end

    def reserve_release_all_connection
      @slaves.each_value do |s|
        s.reserve_release_connection!
      end
      ConfFile.conf_clear!
    end

    def slaves
      @slaves.fetch_or_store(current_thread_id) do |_|
        get_slaves
      end
    end

    def get_slaves
      SlaveGroup.new(slaves_conf, slave_group)
    end

    def slaves_conf
      ConfFile.slaves_conf(slave_group)
    end

    def current_thread_id
      Thread.current.object_id
    end
  end
end
