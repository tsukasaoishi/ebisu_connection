require 'yaml'
require 'active_record'
require 'ebisu_connection'
require 'erb'

case ENV['DB_ADAPTER']
when 'mysql2'
  puts "[mysql2]"
  system("mysql -uroot -h127.0.0.1 < test/config/mysql_schema.sql")
when 'postgresql'
  puts "postgresql"
  system("psql -h 127.0.0.1 -U postgres -c 'CREATE DATABASE ebisu_connection_test_master'")
  system("psql -h 127.0.0.1 -U postgres -c 'CREATE DATABASE ebisu_connection_test_replica'")
  system("psql -h 127.0.0.1 -U postgres -d ebisu_connection_test_master < test/config/psql_test_master.sql > /dev/null 2>&1")
  system("psql -h 127.0.0.1 -U postgres -d ebisu_connection_test_replica < test/config/psql_test_replica.sql > /dev/null 2>&1")
end

module ActiveRecord
  class Base
    d = File.read(File.join(__dir__, "database_#{ENV['DB_ADAPTER']}.yml"))
    self.configurations = YAML.load(ERB.new(d).result)
    establish_connection(configurations["test"])
    establish_fresh_connection
  end
end

class User < ActiveRecord::Base
end

require "support/extend_minitest"
