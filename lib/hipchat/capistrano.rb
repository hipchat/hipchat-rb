require 'hipchat'

Capistrano::Configuration.instance(:must_exist).load do
  set :hipchat_send_notification, false
  set :hipchat_with_migrations, false

  namespace :hipchat do
    task :set_client do
      set :hipchat_client, HipChat::Client.new(hipchat_token)
    end

    task :trigger_notification do
      set :hipchat_send_notification, true
    end

    task :configure_for_migrations do
      set :hipchat_with_migrations, true
    end

    task :notify_deploy_started do
      if hipchat_send_notification
        on_rollback do
          hipchat_client[hipchat_room_name].
            send(deploy_user, "#{human} cancelled deployment of #{application} to #{rails_env}.", hipchat_announce)
        end

        message = "#{human} is deploying #{application} to #{rails_env}"
        message << " (with migrations)" if hipchat_with_migrations
        message << "."

        hipchat_client[hipchat_room_name].
          send(deploy_user, message, hipchat_announce)
      end
    end

    task :notify_deploy_finished do
      hipchat_client[hipchat_room_name].
        send(deploy_user, "#{human} finished deploying #{application} to #{rails_env}.", hipchat_announce)
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

    def rails_env
      fetch(:hipchat_env, fetch(:rails_env, "production"))
    end
  end

  before "hipchat:notify_deploy_started", "hipchat:set_client"
  before "deploy", "hipchat:trigger_notification"
  before "deploy:migrations", "hipchat:trigger_notification", "hipchat:configure_for_migrations"
  before "deploy:update_code", "hipchat:notify_deploy_started"
  after  "deploy", "hipchat:notify_deploy_finished"
  after  "deploy:migrations", "hipchat:notify_deploy_finished"
end
