require 'hipchat'

namespace :hipchat do
  desc "Sends a HipChat message as a particular user"
  task :send, [:message] do |t, args|
    required_options = [:message, :room, :token, :user]
    config_file      = Rails.root.join 'config', 'hipchat.yml'

    options = {
      :message        => ENV['MESSAGE'],
      :message_format => ENV['MESSAGE_FORMAT'],
      :user           => ENV['HIPCHAT_USER'],
      :notify         => ENV['NOTIFY'],
      :room           => ENV['ROOM'],
      :color          => ENV['COLOR'],
      :token          => ENV['TOKEN'],
      :api_version    => ENV['API_VERSION'],
      :server_url     => ENV['SERVER_URL']
    }.reject { |k, v| v.blank? }

    system_options = {
      :user    => ENV['USER']
    }.reject { |k, v| v.blank? }

    argument_options = {
      :message => args.message
    }.reject { |k, v| v.blank? }

    if File.exists? config_file
      options.reverse_merge! YAML.load_file(config_file).symbolize_keys
    end

    options.reverse_merge! system_options
    options.merge! argument_options

    options[:notify] = options[:notify].to_s != 'false'

    if (missing_options = required_options - options.keys).size > 0
      puts "HipChat needs #{missing_options.to_sentence} to send!"
      exit
    end

    client = HipChat::Client.new(options[:token], options)

    options[:room].each do |r|
      client[r].send(options[:user], options[:message], { :color => options[:color], :notify => options[:notify] })
    end
  end
end
