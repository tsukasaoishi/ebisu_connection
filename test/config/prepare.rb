require 'yaml'
require 'active_record'
require 'ebisu_connection'

case ENV['DB_ADAPTER']
when 'mysql2'
  puts "[mysql2]"
  system("mysql -uroot < test/config/mysql_schema.sql")
when 'postgresql'
  puts "postgresql"
  system("psql ebisu_connection_test_master < test/config/psql_test_master.sql > /dev/null 2>&1")
  system("psql ebisu_connection_test_slave < test/config/psql_test_slave.sql > /dev/null 2>&1")
end

module ActiveRecord
  class Base
    self.configurations = YAML.load_file(File.join(__dir__, "database_#{ENV['DB_ADAPTER']}.yml"))
    establish_connection(configurations["test"])
  end
end

class User < ActiveRecord::Base
end

require "support/extend_minitest"
