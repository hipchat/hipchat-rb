require 'httparty'
require 'ostruct'

require 'hipchat/railtie' if defined?(Rails::Railtie)

module HipChat
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UnknownResponseCode < StandardError; end

  class Client
    include HTTParty

    base_uri 'https://api.hipchat.com/v1/rooms'
    format :json

    def initialize(token)
      @token = token
    end

    def rooms
      @rooms ||= self.class.get("/list", :query => {:auth_token => @token})['rooms'].
        map { |r| Room.new(@token, r) }
    end

    def [](name)
      Room.new(@token, :room_id => name)
    end
  end

  class Room < OpenStruct
    include HTTParty

    base_uri 'https://api.hipchat.com/v1/rooms'

    def initialize(token, params)
      @token = token

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
      options = if options_or_notify == true or options_or_notify == false
        warn "DEPRECATED: Specify notify flag as an option (e.g., :notify => true)"
        { :notify => options_or_notify }
      else
        options_or_notify || {}
      end

      options = { :color => 'yellow', :notify => false }.merge options

      response = self.class.post('/message',
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => from,
          :message        => message,
          :message_format => options[:message_format] || 'html',
          :color          => options[:color],
          :notify         => options[:notify] ? 1 : 0
        }
      )

      case response.code
      when 200; true
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
