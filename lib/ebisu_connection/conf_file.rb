module EbisuConnection
  class ConfFile
    class << self
      attr_writer :slaves_file, :check_interval

      def if_modify
        if time_to_check? && modify?
          yield
        end
      end

      def conf_clear!
        @slaves_conf = nil
        @spec = nil
      end

      def slaves_conf(slave_group)
        @slaves_conf ||= get_slaves_conf
        if @slaves_conf.is_a?(Hash)
          @slaves_conf[slave_group] || @slaves_conf
        else
          @slaves_conf
        end
      end

      def spec(slave_group)
        @spec ||= get_spec
        @spec.merge(@spec[slave_group] || {})
      end

      def slaves_file
        @slaves_file || File.join(Rails.root, "config/slave.yaml")
      end

      def check_interval
        @check_interval || 1.minute
      end

      private

      def time_to_check?
        now = Time.now
        @check_time ||= now

        return false if now - @check_time < check_interval

        @check_time = now
        true
      end

      def modify?
        @file_mtime != File.mtime(slaves_file)
      end

      def get_slaves_conf
        @file_mtime = File.mtime(slaves_file)
        conf = YAML.load_file(slaves_file)
        conf[Rails.env.to_s] || {}
      end

      def get_spec
        ActiveRecord::Base.configurations[Rails.env]
      end
    end
  end
end
