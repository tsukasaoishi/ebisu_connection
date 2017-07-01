require 'yaml'
require 'active_support/deprecation'

module EbisuConnection
  class ConfFile
    class << self
      attr_writer :replica_file

      def slaves_file=(file)
        ActiveSupport::Deprecation.warn(
          "'slaves_file=' is deprecated and will removed from version 2.4.0. use 'replica_file=' insted."
        )

        self.replica_file = file
      end

      def replica_conf(replica_group)
        @replica_conf ||= get_replica_conf

        if @replica_conf.is_a?(Hash)
          c = @replica_conf[replica_group]

          if !c && replica_group == "replica" && @replica_conf.key?("slave")
            ActiveSupport::Deprecation.warn(
              "'slave' in replica.yml is deprecated and will ignored from version 2.4.0. use 'replica' insted."
            )

            c = @replica_conf["slave"]
          end

          c || @replica_conf
        else
          @replica_conf
        end
      end

      def slaves_conf(replica_group)
        ActiveSupport::Deprecation.warn(
          "'slaves_conf' is deprecated and will removed from version 2.4.0. use 'replica_conf' insted."
        )

        replica_conf(replica_group)
      end

      def replica_file
        return @replica_file if @replica_file
        raise "nothing replica_file. You have to set a file path using EbisuConnection.replica_file= method" unless defined?(Rails)

        file = %w(yml yaml).map{|ext| Rails.root.join("config/replica.#{ext}").to_s }.detect {|f| File.exist?(f) }

        unless file
          file = %w(yml yaml).map{|ext| Rails.root.join("config/slave.#{ext}").to_s }.detect {|f| File.exist?(f) }
          if file
            ActiveSupport::Deprecation.warn(
              "file name 'config/#{file}' is deprecated and will ignored from version 2.4.0. use 'config/replica.yml' insted."
            )
          end
        end

        raise "nothing replica_file. You have to put a config/replica.yml file" unless file

        @replica_file = file
      end

      def slaves_file
        ActiveSupport::Deprecation.warn(
          "'slaves_file' is deprecated and will removed from version 2.4.0. use 'replica_file' insted."
        )

        replica_file
      end

      private

      def get_replica_conf
        @file_mtime = File.mtime(replica_file)
        conf = YAML.load_file(replica_file)
        conf[EbisuConnection.env.to_s] || {}
      end
    end
  end
end
