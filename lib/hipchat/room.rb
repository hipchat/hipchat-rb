require 'httparty'
require 'ostruct'

module HipChat

  class Room < OpenStruct
    include HTTParty
    include FileHelper

    format   :json

    def initialize(token, params)
      @token = token
      @api = HipChat::ApiVersion::Room.new(params)
      self.class.base_uri(@api.base_uri)
      super(params)
    end

    # Retrieve data for this room
    def get_room
      response = self.class.get(@api.get_room_config[:url],
        :query => {:auth_token => @token }.merge(@api.get_room_config[:query_params]),
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      response.parsed_response
    end

    # Update a room
    def update_room(options = {})
      options = {
        :privacy => 'public',
        :is_archived => false,
        :is_guest_accessible => false
      }.merge symbolize(options)

      response = self.class.send(@api.topic_config[:method], @api.update_room_config[:url],
        :query => { :auth_token => @token },
        :body => {
          :name => options[:name],
          :topic => options[:topic],
          :privacy => options[:privacy],
          :is_archived => @api.bool_val(options[:is_archived]),
          :is_guest_accessible => @api.bool_val(options[:is_guest_accessible]),
          :owner => options[:owner]
        }.to_json,
        :headers => @api.headers)

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end

    # Delete a room
    def delete_room
      response = self.class.delete(@api.delete_room_config[:url],
        :query => { :auth_token => @token },
        :headers => @api.headers)
      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end

    # Invite user to this room
    def invite(user, reason='')
      response = self.class.post(@api.invite_config[:url]+"/#{user}",
        :query => { :auth_token => @token },
        :body => {
          :reason => reason
        }.to_json,
        :headers => @api.headers)

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end

    # Add member to this room
    def add_member(user, room_roles=['room_member'])
      response = self.class.put(@api.add_member_config[:url]+"/#{user}",
        :query => { :auth_token => @token },
        :body => {
          :room_roles => room_roles
        }.to_json,
        :headers => @api.headers)

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end


    # Send a message to this room.
    #
    # Usage:
    #
    #   # Default
    #   send 'some message'
    #
    def send_message(message)
      response = self.class.post(@api.send_message_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id => room_id,
          :message => message,
        }.send(@api.send_config[:body_format]),
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end


    # Send a notification message to this room.
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
        warn 'DEPRECATED: Specify notify flag as an option (e.g., :notify => true)'
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

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end

    def share_link(from, message, link)
      if from.length > 15
        raise UsernameTooLong, "Username #{from} is `#{from.length} characters long. Limit is 15'"
      end

      response = self.class.post(@api.share_link_config[:url],
        :query => { :auth_token => @token },
        :body  => {
          :room_id        => room_id,
          :from           => from,
          :message        => message,
          :link           => link,
        }.send(@api.send_config[:body_format]),
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
    end

    # Send a file to this room.
    #
    # Usage:
    #
    #   # Default
    #   send_file 'nickname', 'some message', File.open("/path/to/file")
    def send_file(from, message, file)
      if from.length > 15
        raise UsernameTooLong, "Username #{from} is `#{from.length} characters long. Limit is 15'"
      end

      response = self.class.post(@api.send_file_config[:url],
        :query => { :auth_token => @token },
        :body  => file_body(
          {
            :room_id        => room_id,
            :from           => from,
            :message        => message,
          }.send(@api.send_config[:body_format]), file
        ),
        :headers => file_body_headers(@api.headers)
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
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

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      true
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

      options = {
        :date => 'recent',
        :timezone => 'UTC',
        :format => 'JSON',
        :'max-results' => 100,
        :'start-index' => 0
      }.merge options

      response = self.class.get(@api.history_config[:url],
        :query => {
          :room_id    => room_id,
          :date       => options[:date],
          :timezone   => options[:timezone],
          :format     => options[:format],
          :'max-results' => options[:'max-results'],
          :'start-index' => options[:'start-index'],
          :auth_token => @token
        },
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      response.body
    end

    # Pull this room's statistics
    def statistics(options = {})

      response = self.class.get(@api.statistics_config[:url],
        :query => {
          :room_id    => room_id,
          :date       => options[:date],
          :timezone   => options[:timezone],
          :format     => options[:format],
          :auth_token => @token,
        },
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      response.body
    end

    # Create a webhook for this room
    #
    # Usage:
    #
    #   # Default
    #   create_webhook 'http://example.org/path/to/my/webhook', 'room_event'
    #
    # Options:
    #
    # +pattern+::  The regular expression pattern to match against messages. Only applicable for message events.
    #                (default "")
    # +name+::     The label for this webhook
    #                (default "")
    def create_webhook(url, event, options = {})
      raise InvalidEvent unless %w(room_message room_notification room_exit room_enter room_topic_change room_archived room_deleted room_unarchived).include? event

      begin
        u = URI::parse(url)
        raise InvalidUrl unless %w(http https).include? u.scheme
      rescue URI::InvalidURIError
        raise InvalidUrl
      end

      options = {
        :pattern => '',
        :name => ''
      }.merge options

      response = self.class.post(@api.webhook_config[:url],
        :query => {
          :auth_token => @token
        },
        :body => {:url => url, :pattern => options[:pattern], :event => event, :name => options[:name]}.send(@api.send_config[:body_format]),
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      response.body
    end

    # Delete a webhook for this room
    #
    # Usage:
    #
    #   # Default
    #   delete_webhook 'webhook_id'
    def delete_webhook(webhook_id)
      response = self.class.delete("#{@api.webhook_config[:url]}/#{URI::escape(webhook_id)}",
                                 :query => {
                                   :auth_token => @token
                                 },
                                 :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :webhook, webhook_id, response
      true
    end

    # Gets all webhooks for this room
    #
    # Usage:
    #
    #   # Default
    #   get_all_webhooks
    #
    # Options:
    #
    # +start-index+::  The regular expression pattern to match against messages. Only applicable for message events.
    #                (default "")
    # +max-results+::     The label for this webhook
    #                (default "")
    def get_all_webhooks(options = {})
      options = {:'start-index' => 0, :'max-results' => 100}.merge(options)

      response = self.class.get(@api.webhook_config[:url],
                                   :query => {
                                     :auth_token => @token,
                                     :'start-index' => options[:'start-index'],
                                     :'max-results' => options[:'max-results']
                                   },
                                   :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :room, room_id, response
      response.body
    end

    # Get a webhook for this room
    #
    # Usage:
    #
    #   # Default
    #   get_webhook 'webhook_id'
    def get_webhook(webhook_id)
      response = self.class.get("#{@api.webhook_config[:url]}/#{URI::escape(webhook_id)}",
                                :query => {
                                  :auth_token => @token
                                },
                                :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :webhook, webhook_id, response
      response.body
    end

    private
      def symbolize(obj)
        return obj.reduce({}) do |memo, (k, v)|
          memo.tap { |m| m[k.to_sym] = symbolize(v) }
        end if obj.is_a? Hash

        return obj.reduce([]) do |memo, v|
          memo << symbolize(v); memo
        end if obj.is_a? Array
        obj
      end

  end
end
