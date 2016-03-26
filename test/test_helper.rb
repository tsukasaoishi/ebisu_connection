require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ebisu_connection'
EbisuConnection.env = "test"
EbisuConnection.slaves_file = File.join(__dir__, "config/slave.yml")

require "config/prepare"
