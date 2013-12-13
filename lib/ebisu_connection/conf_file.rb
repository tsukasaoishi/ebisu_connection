module EbisuConnection
  class ConfFile
    class << self
      attr_writer :slaves_file, :check_interval
      attr_accessor :slave_type

      def if_modify
        if time_to_check? && modify?
          yield
        end
      end

      def conf_clear!
        @slaves_conf = nil
        @spec = nil
      end

      def slaves_conf
        @slaves_conf ||= get_slaves_conf
      end

      def spec
        @spec ||= get_spec
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
        conf = conf[Rails.env.to_s] if conf.is_a?(Hash)
        slave_type ? conf[slave_type.to_s] : conf
      end

      def get_spec
        ret = ActiveRecord::Base.configurations[Rails.env]
        ret.merge(ret["slave"] || {})
      end
    end
  end
end
