require "fresh_connection"
require "active_support/core_ext/module/delegation"

module EbisuConnection
  extend ActiveSupport::Autoload

  autoload :ConfFile
  autoload :ConnectionManager
  autoload :SlaveGroup
  autoload :Slave
  autoload :GreatestCommonDivisor

  class << self
    delegate :slaves_file=, :check_interval=, :to => ConfFile
  end
end

FreshConnection.connection_manager = EbisuConnection::ConnectionManager
