require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ebisu_connection'
EbisuConnection.env = "test"
EbisuConnection.replica_file = File.join(__dir__, "config/replica.yml")

require "config/prepare"
