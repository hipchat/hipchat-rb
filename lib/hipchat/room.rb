require 'httparty'
require 'ostruct'

module HipChat

  class Room < OpenStruct
    include HTTParty

    format   :json

    def initialize(token, params)
      @token = token
      @api = HipChat::ApiVersion::Room.new(params[:room_id],
                                           params.delete(:api_version))
      self.class.base_uri(@api.base_uri)
      super(params)
    end

    # Retrieve data for this room
    def get_room
      response = self.class.get(@api.get_room_config[:url],
        :query => {:auth_token => @token },
        :headers => @api.headers
      )

      case response.code
      when 200
        response.parsed_response
      when 404
        raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401
        raise Unauthorized, "Access denied to room `#{room_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room `#{room_id}'"
      end
    end

    # Invite user to this room
    def invite(user, reason="")
      response = self.class.post(@api.invite_config[:url]+"/#{user}",
        :query => { :auth_token => @token },
        :body => {
          :reason => reason
        }.to_json,
        :headers => @api.headers)

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

      response = self.class.post(@api.send_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => from,
          :message        => message,
          :message_format => options[:message_format] || 'html',
          :color          => options[:color],
          :notify         => @api.bool_val(options[:notify])
        }.send(@api.send_config[:body_format]),
        :headers => @api.headers
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

      response = self.class.send(@api.topic_config[:method], @api.topic_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => options[:from],
          :topic          => new_topic
        }.send(@api.topic_config[:body_format]),
        :headers => @api.headers
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

      response = self.class.get(@api.history_config[:url],
        :query => {
          :room_id    => room_id,
          :date       => options[:date],
          :timezone   => options[:timezone],
          :format     => options[:format],
          :auth_token => @token,
        },
        :headers => @api.headers
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