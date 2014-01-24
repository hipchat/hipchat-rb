$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'hipchat'
require 'rspec'
require 'rspec/autorun'
require 'json'
require 'webmock/rspec'
require 'coveralls'

Dir["./spec/support/**/*.rb"].each {|f| require f}

Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :rr
end
