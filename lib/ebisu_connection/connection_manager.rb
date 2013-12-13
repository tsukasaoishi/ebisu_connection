require 'yaml'

module EbisuConnection
  class ConnectionManager
    CHECK_INTERVAL = 1.minute

    class << self
      attr_writer :slaves_file
      attr_accessor :slave_type

      def slaves_file
        @slaves_file || File.join(Rails.root, "config/slave.yaml")
      end
    end

    def initialize
      @mutex = Mutex.new
    end

    def slave_connection
      slaves.sample.connection
    end

    def put_aside!
      return if check_own_connection
      return unless @file_mtime

      now = Time.now
      @check_time ||= now
      return if now - @check_time < CHECK_INTERVAL
      @check_time = now

      mtime = File.mtime(self.class.slaves_file)
      return if @file_mtime == mtime

      reserve_release_all_connection
      check_own_connection
    end

    def clear_all_connection!
      @mutex.synchronize do
        @slaves ||= {}
        @slaves.values.each do |s|
          s.all_disconnect!
        end

        @slaves = nil
        @slave_conf = nil
        @spec = nil
      end
    end

    private

    def check_own_connection
      ret = false
      @mutex.synchronize do
        @slaves ||= {}
        if s = @slaves[current_thread_id]
          if ret = s.reserved_release?
            s.all_disconnect!
            @slaves.delete(current_thread_id)
          end
        end
      end
      ret
    end

    def reserve_release_all_connection
      @mutex.synchronize do
        @slaves ||= {}
        @slaves.values.each do |s|
          s.reserve_release_connection!
        end
        @slave_conf = nil
        @spec = nil
      end
    end

    def slaves
      @mutex.synchronize do
        @slaves ||= {}
        @slaves[current_thread_id] ||= get_slaves
      end
    end

    def get_slaves
      EbisuConnection::Slaves.new(slaves_conf, spec)
    end

    def slaves_conf
      @slaves_conf ||= get_slaves_conf
    end

    def spec
      @spec ||= get_spec
    end

    def get_slaves_conf
      @file_mtime = File.mtime(self.class.slaves_file)
      conf = YAML.load_file(self.class.slaves_file)
      conf = conf[Rails.env] if conf.is_a?(Hash)
      self.class.slave_type ? conf[self.class.slave_type] : conf
    end

    def get_spec
      ret = ActiveRecord::Base.configurations[Rails.env]
      ret.merge(ret["slave"] || {})
    end

    def current_thread_id
      Thread.current.object_id
    end
  end
end
