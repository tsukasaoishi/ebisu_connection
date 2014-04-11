require "fresh_connection"

module EbisuConnection
  extend ActiveSupport::Autoload

  autoload :ConfFile
  autoload :ConnectionManager
  autoload :Slaves

  class << self
    delegate :slaves_file, :slaves_file=, :check_interval, :check_interval=, :to => ConfFile
  end
end

FreshConnection.connection_manager = EbisuConnection::ConnectionManager
