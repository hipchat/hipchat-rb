require 'hipchat'

namespace :hipchat do
  desc "Sends a HipChat message as a particular user"
  task :send do
    required_options = [:message, :room, :token, :user]
    config_file      = Rails.root.join 'config', 'hipchat.yml'

    options = {
      :message => ENV['MESSAGE'],
      :user    => ENV['USER'],
      :notify  => ENV['NOTIFY'],
      :room    => ENV['ROOM'],
      :token   => ENV['TOKEN']
    }.reject { |k, v| v.blank? }

    if File.exists? config_file
      options.reverse_merge! YAML.load_file(config_file).symbolize_keys
    end

    options[:notify] = options[:notify].to_s != 'false'

    if (missing_options = required_options - options.keys).size > 0
      puts "HipChat needs #{missing_options.to_sentence} to send!"
      exit
    end

    client = HipChat::Client.new(options[:token])

    client[options[:room]].send(options[:user], options[:message], options[:notify])
  end
end
