require 'yaml'
require 'active_record'

system("mysql -uroot < spec/db_schema.sql")

module ActiveRecord
  class Base
    self.configurations = YAML.load_file(File.join(File.dirname(__FILE__), "database.yml"))
    establish_connection(configurations["test"])
  end
end

class User < ActiveRecord::Base
end
