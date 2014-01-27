require 'uri'

module HipChat
  class ApiVersion

    class Client

      def initialize(version = 'v1')
        @version = !version.nil? ? version : 'v1'
        if @version.eql?('v1')
          @base_uri = "https://api.hipchat.com/v1/rooms"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/x-www-form-urlencoded'}
        else
          @base_uri = "https://api.hipchat.com/v2/room"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/json'}
        end
      end

      attr_reader :version, :base_uri, :headers

      def rooms_config
        {
          'v1' => {
            :url => '/list',
            :data_key => 'rooms'
          },
          'v2' => {
            :url => '/room',
            :data_key => 'items'
          }
        }[version]
      end
    end

    class Room

      def initialize(room_id, version = 'v1')
        @room_id = room_id
        @version = !version.nil? ? version : 'v1'
        if @version.eql?('v1')
          @base_uri = "https://api.hipchat.com/v1/rooms"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/x-www-form-urlencoded'}
        else
          @base_uri = "https://api.hipchat.com/v2/room"
          @headers = {'Accept' => 'application/json',
             'Content-Type' => 'application/json'}
        end
      end

      attr_reader :version, :base_uri, :room_id, :headers

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

      def bool_val(opt)
        if version.eql?('v1')
          opt ? 1 : 0
        else
          opt
        end
      end

    end
  end
end
