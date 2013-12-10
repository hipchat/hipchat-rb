require 'httparty'
require 'ostruct'

require 'hipchat/railtie' if defined?(Rails::Railtie)
require "hipchat/version"
require 'hipchat/api_version'

module HipChat
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UnknownResponseCode < StandardError; end
  class UsernameTooLong < StandardError; end

  class Client
    include HTTParty

    format :json

    def initialize(token, options={})
      @token = token
      @api_version = options[:api_version]
      @config = HipChat::ApiVersion.new(@api_version).rooms
      http_proxy = options[:http_proxy] || ENV['http_proxy']
      setup_proxy(http_proxy) if http_proxy
    end

    def rooms
      self.class.base_uri(@config[:base_uri])
      @rooms ||= self.class.get(@config[:url], :query => {:auth_token => @token})['items'].
        map { |r| Room.new(@token, r) }
    end

    def [](name)
      Room.new(@token, :room_id => name, :api_version => @api_version)
    end

    private
    def setup_proxy(proxy_url)
      proxy_url = URI.parse(proxy_url)

      self.class.http_proxy(proxy_url.host, proxy_url.port,
                            proxy_url.user, proxy_url.password)
      HipChat::Room.http_proxy(proxy_url.host, proxy_url.port,
                               proxy_url.user, proxy_url.password)
    end
  end

  class Room < OpenStruct
    include HTTParty

    format   :json
    headers  'Accept' => 'application/json',
             'Content-Type' => 'application/json'

    def initialize(token, params)
      @token = token
      @api = HipChat::ApiVersion.new(params.delete(:api_version))
      super(params)
    end

    # Send a message to this room.
    #
    # Usage:
    #
    #   # Default
    #   send 'nickname', 'some message'
    #
    #   # Notify users and color the message red
    #   send 'nickname', 'some message', :notify => true, :color => 'red'
    #
    #   # Notify users (deprecated)
    #   send 'nickname', 'some message', true
    #
    # Options:
    #
    # +color+::  "yellow", "red", "green", "purple", or "random"
    #            (default "yellow")
    # +notify+:: true or false
    #            (default false)
    def send(from, message, options_or_notify = {})
      if from.length > 15
        raise UsernameTooLong, "Username #{from} is `#{from.length} characters long. Limit is 15'"
      end
      options = if options_or_notify == true or options_or_notify == false
        warn "DEPRECATED: Specify notify flag as an option (e.g., :notify => true)"
        { :notify => options_or_notify }
      else
        options_or_notify || {}
      end

      options = { :color => 'yellow', :notify => false }.merge options

      send_config = @api.send(room_id)
      self.class.base_uri(send_config[:base_uri])
      response = self.class.post(send_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => from,
          :message        => message,
          :message_format => options[:message_format] || 'html',
          :color          => options[:color],
          :notify         => @api.bool_val(options[:notify])
        }.send(send_config[:body_format])
      )

      case response.code
      when 200, 204; true
      when 404
        raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401
        raise Unauthorized, "Access denied to room `#{room_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room `#{room_id}'"
      end
    end

    # Change this room's topic
    #
    # Usage:
    #
    #   # Default
    #   topic 'my awesome topic'
    #
    # Options:
    #
    # +from+::  the name of the person changing the topic
    #            (default "API")
    def topic(new_topic, options = {})

      options = { :from => 'API' }.merge options

      topic_config = @api.topic(room_id)
      self.class.base_uri(topic_config[:base_uri])
      response = self.class.send(topic_config[:method], topic_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => options[:from],
          :topic          => new_topic
        }.send(topic_config[:body_format])
      )

      case response.code
      when 204,200; true
      when 404
        raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401
        raise Unauthorized, "Access denied to room `#{room_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room `#{room_id}'"
      end
    end

    # Pull this room's history
    #
    # Usage
    #
    #   # Default
    #
    #
    # Options
    #
    # +date+::     Whether to return a specific day (YYYY-MM-DD format) or recent
    #                (default "recent")
    # +timezone+:: Your timezone.  Supported timezones are at: https://www.hipchat.com/docs/api/timezones
    #                (default "UTC")
    # +format+::   Format to retrieve the history in.  Valid options are JSON and XML
    #                (default "JSON")
    def history(options = {})

      options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON' }.merge options

      self.class.base_uri(@api.history(room_id)[:base_uri])
      response = self.class.get(@api.history(room_id)[:url],
        :query => {
          :room_id    => room_id,
          :date       => options[:date],
          :timezone   => options[:timezone],
          :format     => options[:format],
          :auth_token => @token,
        }
      )

      case response.code
      when 200
        response.body
      when 404
        raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401
        raise Unauthorized, "Access denied to room `#{room_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room `#{room_id}'"
      end
    end
  end
end
