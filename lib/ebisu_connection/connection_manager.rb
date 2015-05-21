require 'fresh_connection/abstract_connection_manager'
require 'ebisu_connection/conf_file'
require 'ebisu_connection/slave_group'
require 'active_support/deprecation'

module EbisuConnection
  class ConnectionManager < FreshConnection::AbstractConnectionManager
    def initialize(slave_group = "slave")
      super
      @slaves = {}
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

    def recovery(failure_connection, exception)
      if slave_down_message?(exception.message)
        slaves.remove_connection(failure_connection)
        true
      else
        false
      end
    end

    def clear_all_connections!
      synchronize do
        @slaves.values.each do |s|
          s.all_disconnect!
        end

        @slaves = {}
        ConfFile.conf_clear!
      end
    end

    def clear_all_connection!
      ActiveSupport::Deprecation.warn("clear_all_connection! has been deprecated. Use clear_all_connections! instead", caller)
      clear_all_connections!
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
        ConfFile.conf_clear!
      end
    end

    def slaves
      synchronize do
        @slaves[current_thread_id] ||= get_slaves
      end
    end

    def get_slaves
      SlaveGroup.new(slaves_conf, slave_group)
    end

    def slaves_conf
      ConfFile.slaves_conf(slave_group)
    end
  end
end
