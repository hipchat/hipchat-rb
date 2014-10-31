require 'uri'

module HipChat
  class ApiVersion

    def bool_val(opt)
      if version.eql?('v1')
        opt ? 1 : 0
      else
        opt
      end
    end

    class Client < ApiVersion

      def initialize(options = {})
        # puts options.inspect
        @version = options[:api_version]
        if @version.eql?('v1')
          @base_uri = "#{options[:server_url]}/v1"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/x-www-form-urlencoded'}
        else
          @base_uri = "#{options[:server_url]}/v2"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/json'}
        end
      end

      attr_reader :version, :base_uri, :headers

      def rooms_config
        {
          'v1' => {
            :url => '/rooms/list',
            :data_key => 'rooms'
          },
          'v2' => {
            :url => '/room',
            :data_key => 'items'
          }
        }[version]
      end


      def create_room_config
        {
          'v1' => {
            :url => '/rooms/create',
            :body_format => :to_hash
          },
          'v2' => {
            :url => '/room',
            :body_format => :to_json
          }
        }[version]
      end

      def users_config
        {
          :url => '/user',
          :data_key => 'items'
        }
      end
    end

    class Room < ApiVersion

      def initialize(options = {})
        @room_id = options[:room_id]
        @version = options[:api_version]
        if @version.eql?('v1')
          @base_uri = "#{options[:server_url]}/v1/rooms"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/x-www-form-urlencoded'}
        else
          @base_uri = "#{options[:server_url]}/v2/room"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/json'}
        end
      end

      attr_reader :version, :base_uri, :room_id, :headers

      def get_room_config
        {
          'v2' => {
            :url => URI::escape("/#{room_id}")
          }
        }[version]
      end

      def update_room_config
        {
          "v2" => {
            :url => URI::escape("/#{room_id}"),
            :method => :put,
            :body_format => :to_json
          }
        }[version]
      end

      def invite_config
        {
          'v2' => {
            :url => URI::escape("/#{room_id}/invite"),
            :body_format => :to_json
          }
        }[version]
      end

      def send_config
        {
          'v1' => {
            :url => "/message",
            :body_format => :to_hash
          },
          'v2' => {
            :url => URI::escape("/#{room_id}/notification"),
            :body_format => :to_json
          }
        }[version]
      end

      def topic_config
        {
          'v1' => {
            :url => '/topic',
            :method => :post,
            :body_format => :to_hash
          },
          'v2' => {
            :url => URI::escape("/#{room_id}/topic"),
            :method => :put,
            :body_format => :to_json
          }
        }[version]
      end

      def history_config
        {
          'v1' => {
            :url => '/history'
          },
          'v2' => {
            :url => URI::escape("/#{room_id}/history")
          }
        }[version]
      end

      def statistics_config
        {
          'v2' => {
            :url => URI::escape("/#{room_id}/statistics")
          }
        }[version]
      end
    end

    class User

      def initialize(user_id, options)
        @user_id = user_id
        raise InvalidApiVersion,  "user API calls invalid for API v1" if ! options[:api_version].eql?('v2')
        @base_uri = "#{options[:server_url]}/v2/user"
        @headers = {'Accept' => 'application/json',
          'Content-Type' => 'application/json'}
      end

      attr_reader :version, :base_uri, :user_id, :headers

      def send_config
        {
          :url => URI::escape("/#{user_id}/message"),
          :body_format => :to_json
        }
      end

      def view_config
        {
          :url => URI::escape("/#{user_id}"),
          :body_format => :to_json
        }
      end
    end
  end
end
