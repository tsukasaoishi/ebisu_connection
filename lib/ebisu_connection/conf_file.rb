require 'yaml'
require 'active_support/deprecation'

module EbisuConnection
  class ConfFile
    class << self
      attr_writer :replica_file

      def slaves_file=(file)
        ActiveSupport::Deprecation.warn(
          "'slaves_file=' is deprecated and will removed from version 2.5.0. use 'replica_file=' instead."
        )

        self.replica_file = file
      end

      def replica_conf(spec_name)
        return config unless config.is_a?(Hash)

        c = config[spec_name]
        return c if c

        if spec_name == "replica" && config.key?("slave")
          ActiveSupport::Deprecation.warn(
            "'slave' in replica.yml is deprecated and will ignored from version 2.5.0. use 'replica' insted."
          )

          c = config["slave"]
        end

        c || config
      end

      private

      def config
        return @config if defined?(@config)

        conf = YAML.load_file(replica_file)
        @config = conf[EbisuConnection.env.to_s] || {}
      end

      def replica_file
        return @replica_file if @replica_file

        raise "nothing replica_file. You have to set a file path using EbisuConnection.replica_file= method" unless defined?(Rails)

        file = %w(yml yaml).map{|ext| Rails.root.join("config/replica.#{ext}").to_s }.detect {|f| File.exist?(f) }
        return file if file

        file = %w(yml yaml).map{|ext| Rails.root.join("config/slave.#{ext}").to_s }.detect {|f| File.exist?(f) }
        if file
          ActiveSupport::Deprecation.warn(
            "file name 'config/#{file}' is deprecated and will ignored from version 2.5.0. use 'config/replica.yml' insted."
          )

          return file
        end

        raise "nothing replica_file. You have to put a config/replica.yml file"
      end
    end
  end
end
