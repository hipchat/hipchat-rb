require 'hipchat'

namespace :hipchat do

  task :notify_deploy_started do
    send_message("#{human} is deploying #{deployment_name} to #{environment_string}.", send_options)
  end

  task :notify_deploy_finished do
    send_options.merge!(:color => success_message_color)
    send_message("#{human} finished deploying #{deployment_name} to #{environment_string}.", send_options)
  end

  task :notify_deploy_reverted do
    send_options.merge!(:color => failed_message_color)
    send_message("#{human} cancelled deployment of #{deployment_name} to #{environment_string}.", send_options)
  end

  def send_options
    return @send_options if defined?(@send_options)
    @send_options = message_format ? {:message_format => message_format } : {}
    @send_options.merge!(:notify => message_notification)
    @send_options.merge!(:color => message_color)
    @send_options
  end

  def send_message(message, options)
    return unless enabled?

    hipchat_token = fetch(:hipchat_token)
    hipchat_room_name = fetch(:hipchat_room_name)
    hipchat_options = fetch(:hipchat_options, {})

    hipchat_client = fetch(:hipchat_client, HipChat::Client.new(hipchat_token, hipchat_options))

    if hipchat_room_name.is_a?(String)
      rooms = [hipchat_room_name]
    elsif hipchat_room_name.is_a?(Symbol)
      rooms = [hipchat_room_name.to_s]
    else
      rooms = hipchat_room_name
    end

    rooms.each { |room|
      begin
        hipchat_client[room].send(deploy_user, message, options)
      rescue => e
        puts e.message
        puts e.backtrace
      end
    }
  end

  def enabled?
    fetch(:hipchat_enabled, true)
  end

  def environment_string
    if fetch(:stage)
      "#{fetch(:stage)} (#{environment_name})"
    else
      environment_name
    end
  end

  def deployment_name
    if fetch(:branch, nil)
      application = fetch(:application)
      branch = fetch(:branch)
      real_revision = fetch(:real_revision)

      name = "#{application}/#{branch}"
      name += " (revision #{real_revision[0..7]})" if real_revision
      name
    else
      application
    end
  end

  def message_color
    fetch(:hipchat_color, 'yellow')
  end

  def success_message_color
    fetch(:hipchat_success_color, 'green')
  end

  def failed_message_color
    fetch(:hipchat_failed_color, 'red')
  end

  def message_notification
    fetch(:hipchat_announce, false)
  end

  def message_format
    fetch(:hipchat_message_format, 'html')
  end

  def deploy_user
    fetch(:hipchat_deploy_user, 'Deploy')
  end

  def human
    user = ENV['HIPCHAT_USER'] || fetch(:hipchat_human)
    user = user || if (u = %x{git config user.name}.strip) != ''
                     u
                   elsif (u = ENV['USER']) != ''
                     u
                   else
                     'Someone'
                   end
    user
  end

  def environment_name
    fetch(:hipchat_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage))))
  end

  before 'deploy:starting', 'hipchat:notify_deploy_started'
  after 'deploy:finished', 'hipchat:notify_deploy_finished'
  if Rake::Task.task_defined? 'deploy:failed'
    after 'deploy:failed', 'hipchat:notify_deploy_reverted'
  end

end
