require 'yaml'
require 'active_record'

system("mysql -uroot < test/config/db_schema.sql")

module ActiveRecord
  class Base
    self.configurations = YAML.load_file(File.join(__dir__, "database.yml"))
    establish_connection(configurations["test"])
  end
end

class User < ActiveRecord::Base
end

require "support/extend_minitest"
