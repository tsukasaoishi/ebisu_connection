ENV["RAILS_ENV"]="test"
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ebisu_connection'

FreshConnection::Initializer.extend_active_record
FreshConnection.env = "test"
EbisuConnection.slaves_file = File.join(File.dirname(__FILE__), "slaves.yaml")
require File.join(File.dirname(__FILE__), "prepare.rb")
