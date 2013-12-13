require 'yaml'

module EbisuConnection
  class ConnectionManager
    class << self
      delegate :slave_file, :slave_file=, :check_interval, :check_interval=,
        :slave_type, :slave_type=, :to => EbisuConnection::ConfFile

      delegate :ignore_models=, :to => FreshConnection::SlaveConnection
    end

    delegate :if_modify, :conf_clear!, :slaves_conf, :spec,
      :to => EbisuConnection::ConfFile

    def initialize
      @mutex = Mutex.new
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

    def clear_all_connection!
      @mutex.synchronize do
        @slaves.values.each do |s|
          s.all_disconnect!
        end

        @slaves = {}
        conf_clear!
      end
    end

    private

    def check_own_connection
      @mutex.synchronize do
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
      @mutex.synchronize do
        @slaves.values.each do |s|
          s.reserve_release_connection!
        end
        conf_clear!
      end
    end

    def slaves
      @mutex.synchronize do
        @slaves[current_thread_id] ||= get_slaves
      end
    end

    def get_slaves
      EbisuConnection::Slaves.new(slaves_conf, spec)
    end

    def current_thread_id
      Thread.current.object_id
    end
  end
end
