require 'hipchat'

Capistrano::Configuration.instance(:must_exist).load do
  namespace :hipchat do
    task :set_client do
      set :hipchat_client, HipChat::Client.new(hipchat_token)
    end

    task :notify_deploy_started do
      hipchat_client[hipchat_room_name].
        send(deploy_user, "#{human} is deploying #{application} to #{rails_env}.", hipchat_announce)
    end

    task :notify_deploy_finished do
      hipchat_client[hipchat_room_name].
        send(deploy_user, "#{human} finished deploying #{application} to #{rails_env}.", hipchat_announce)
    end

    def deploy_user
      fetch(:hipchat_deploy_user, "Deploy")
    end

    def human
      user = ENV['HIPCHAT_USER'] || fetch(:hipchat_human, ENV['USER'])

      if user == :from_git
        %x{git config user.name}.strip
      else
        user
      end
    end

    def rails_env
      fetch(:hipchat_env, fetch(:rails_env, "production"))
    end
  end

  before "hipchat:notify_deploy_started", "hipchat:set_client"
  before "deploy", "hipchat:notify_deploy_started"
  after  "deploy", "hipchat:notify_deploy_finished"
end
