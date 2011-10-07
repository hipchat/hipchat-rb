require 'hipchat'

module HipChat
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'hipchat/rails3_tasks'
    end
  end
end
