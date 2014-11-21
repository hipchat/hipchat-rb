require 'hipchat/railtie' if defined?(Rails::Railtie)
require 'hipchat/version'

module HipChat
  require 'hipchat/api_version'
  require 'hipchat/errors'
  require 'hipchat/file_helper'
  require 'hipchat/room'
  require 'hipchat/client'
  require 'hipchat/user'
end
