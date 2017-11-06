require 'active_support'
require "fresh_connection"
require "ebisu_connection/conf_file"

module EbisuConnection
  class << self
    attr_writer :env

    def replica_file=(file)
      ConfFile.replica_file = file
    end

    def slaves_file=(file)
      ConfFile.slaves_file = file
    end

    def env
      @env ||= defined?(Rails) && Rails.env || ENV["RAILS_ENV"] || ENV["RACK_ENV"]
    end
  end
end

require "ebisu_connection/connection_manager"
FreshConnection.connection_manager = EbisuConnection::ConnectionManager
