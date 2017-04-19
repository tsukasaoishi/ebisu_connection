require 'active_support/deprecation'
require "fresh_connection"
require "ebisu_connection/conf_file"

module EbisuConnection
  class << self
    attr_writer :env

    def replica_file=(file)
      ConfFile.replica_file = file
    end

    def slaves_file=(file)
      ActiveSupport::Deprecation.warn(
        "'slaves_file=' is deprecated and will removed from version 2.4.0. use 'replica_file=' insted."
      )

      self.replica_file = file
    end

    def check_interval=(interval)
      ConfFile.check_interval = interval
    end

    def env
      @env ||= defined?(Rails) && Rails.env || ENV["RAILS_ENV"] || ENV["RACK_ENV"]
    end
  end
end

require "ebisu_connection/connection_manager"
FreshConnection.connection_manager = EbisuConnection::ConnectionManager
ActiveRecord::Base.establish_fresh_connection
