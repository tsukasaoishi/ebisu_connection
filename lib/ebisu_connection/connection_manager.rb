require 'yaml'
require 'fresh_connection/abstract_connection_manager'

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    delegate :if_modify, :conf_clear!, :to => ConfFile

    def initialize(slave_group = "slave")
      super
      @slaves = {}
    end

    def slave_connection
      slaves.sample.connection
    end

    def put_aside!
      return if check_own_connection

      if_modify do
        reserve_release_all_connection
        check_own_connection
      end
    end

    def recovery(failure_connection, exception)
      if recoverable? && slave_down_message?(exception.message)
        slaves.remove_connection(failure_connection)
        true
      else
        false
      end
    end

    def recoverable?
      true
    end

    def clear_all_connection!
      synchronize do
        @slaves.values.each do |s|
          s.all_disconnect!
        end

        @slaves = {}
        conf_clear!
      end
    end

    private

    def check_own_connection
      synchronize do
        s = @slaves[current_thread_id]

        if s && s.reserved_release?
          s.all_disconnect!
          @slaves.delete(current_thread_id)
          true
        else
          false
        end
      end
    end

    def reserve_release_all_connection
      synchronize do
        @slaves.values.each do |s|
          s.reserve_release_connection!
        end
        conf_clear!
      end
    end

    def slaves
      synchronize do
        @slaves[current_thread_id] ||= get_slaves
      end
    end

    def get_slaves
      SlaveGroup.new(slaves_conf, spec)
    end

    def slaves_conf
      ConfFile.slaves_conf(@slave_group)
    end

    def spec
      ConfFile.spec(@slave_group)
    end
  end
end
