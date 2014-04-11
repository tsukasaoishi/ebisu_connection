require "fresh_connection"

module EbisuConnection
  extend ActiveSupport::Autoload

  autoload :ConfFile
  autoload :ConnectionManager
  autoload :Slaves
end

FreshConnection.connection_manager = EbisuConnection::ConnectionManager
