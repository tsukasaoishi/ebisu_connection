ENV["RAILS_ENV"]="test"
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ebisu_connection'

FreshConnection::Initializer.extend_active_record
