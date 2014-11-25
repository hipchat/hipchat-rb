$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'hipchat'
require 'rspec'
require 'rspec/autorun'
require 'json'
require 'webmock/rspec'

begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
  warn 'warning: coveralls gem not found; skipping coverage'
end

Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
end
