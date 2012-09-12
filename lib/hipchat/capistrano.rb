require 'hipchat'

Capistrano::Configuration.instance(:must_exist).load do
  set :hipchat_send_notification, false
  set :hipchat_with_migrations, ''

  namespace :hipchat do
    task :trigger_notification do
      set :hipchat_send_notification, true
    end

    task :configure_for_migrations do
      set :hipchat_with_migrations, ' (with migrations)'
    end

    task :notify_deploy_started do
      if hipchat_send_notification
        on_rollback do
          send_options.merge!(:color => failed_message_color)
          send("#{human} cancelled deployment of #{deployment_name} to #{env}.", send_options)
        end

        send("#{human} is deploying #{deployment_name} to #{env}#{fetch(:hipchat_with_migrations, '')}.", send_options)
      end
    end

    task :notify_deploy_finished do
      send("#{human} finished deploying #{deployment_name} to #{env}#{fetch(:hipchat_with_migrations, '')}.", send_options)
    end

    def send_options
      return @send_options if defined?(@send_options)
      @send_options = message_format ? {:message_format => message_format } : {}
      @send_options.merge!(:notify => message_notification)
      @send_options.merge!(:color => message_color)
      @send_options
    end

    def send(message, options)
      set :hipchat_client, HipChat::Client.new(hipchat_token) if fetch(:hipchat_client, nil).nil?

      if hipchat_room_name.is_a?(String)
        rooms = [hipchat_room_name]
      elsif hipchat_room_name.is_a?(Symbol)
        rooms = [hipchat_room_name.to_s]
      else
        rooms = hipchat_room_name
      end

      rooms.each { |room|
        hipchat_client[room].send(deploy_user, message, options)
      }
    end

    def deployment_name
      if branch
        name = "#{application}/#{branch}"
        name += " (revision #{current_revision[0..7]})" if current_revision
        name
      else
        application
      end
    end

    def message_color
      fetch(:hipchat_color, nil)
    end

    def failed_message_color
      fetch(:hipchat_failed_color, "red")
    end

    def message_notification
      fetch(:hipchat_announce, false)
    end

    def message_format
      fetch(:hipchat_message_format, "html")
    end

    def deploy_user
      fetch(:hipchat_deploy_user, "Deploy")
    end

    def human
      ENV['HIPCHAT_USER'] ||
        fetch(:hipchat_human,
              if (u = %x{git config user.name}.strip) != ""
                u
              elsif (u = ENV['USER']) != ""
                u
              else
                "Someone"
              end)
    end

    def env
      fetch(:hipchat_env, fetch(:rack_env, fetch(:rails_env, "production")))
    end
  end

  before "deploy", "hipchat:trigger_notification"
  before "deploy:migrations", "hipchat:trigger_notification", "hipchat:configure_for_migrations"
  before "deploy:update_code", "hipchat:notify_deploy_started"
  after  "deploy", "hipchat:notify_deploy_finished"
  after  "deploy:migrations", "hipchat:notify_deploy_finished"
end
