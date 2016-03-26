require "fresh_connection"

module EbisuConnection
  autoload :ConfFile, 'ebisu_connection/conf_file'
  autoload :ConnectionManager, 'ebisu_connection/connection_manager'
  autoload :SlaveGroup, 'ebisu_connection/slave_group'
  autoload :Slave, 'ebisu_connection/slave'
  autoload :GreatestCommonDivisor, 'ebisu_connection/greatest_common_divisor'

  class << self
    attr_writer :env

    def slaves_file=(file)
      ConfFile.slaves_file = file
    end

    def check_interval=(interval)
      ConfFile.check_interval = interval
    end

    def env
      @env ||= defined?(Rails) && Rails.env || ENV["RAILS_ENV"] || ENV["RACK_ENV"]
    end
  end
end

FreshConnection.connection_manager = EbisuConnection::ConnectionManager
