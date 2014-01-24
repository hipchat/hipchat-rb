require 'hipchat/railtie' if defined?(Rails::Railtie)
require "hipchat/version"

module HipChat
  require 'hipchat/errors'
  require 'hipchat/room'
  require 'hipchat/client'
end
