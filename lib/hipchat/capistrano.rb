require 'hipchat'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :hipchat do
    task :set_client do
      set :hipchat_client, HipChat::Client.new(hipchat_token)
    end

    task :notify_deploy_started do
      rails_env = fetch(:hipchat_env, fetch(:rails_env, "production"))

      hipchat_client[hipchat_room_name].
        send(deploy_user, "Started deploying #{application} (#{rails_env}).", hipchat_announce)
    end

    task :notify_deploy_finished do
      hipchat_client[hipchat_room_name].
        send(deploy_user, "Finished deploying #{application}.", hipchat_announce)
    end

    def deploy_user
      fetch(:hipchat_deploy_user, "Deploy")
    end
  end

  before "hipchat:notify_deploy_started", "hipchat:set_client"
  before "deploy", "hipchat:notify_deploy_started"
  after  "deploy", "hipchat:notify_deploy_finished"
end
