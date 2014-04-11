require "fresh_connection"

module EbisuConnection
  extend ActiveSupport::Autoload

  autoload :ConfFile
  autoload :ConnectionManager
  autoload :Slaves
  autoload :GreatestCommonDivisor

  class << self
    delegate :slaves_file=, :check_interval=, :to => ConfFile
  end
end

FreshConnection.connection_manager = EbisuConnection::ConnectionManager
