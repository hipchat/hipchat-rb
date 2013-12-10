module HipChat
  class ApiVersion

    def initialize(version = 'v1')
      @version = !version.nil? ? version : 'v1'
      @host = "https://api.hipchat.com"
    end

    def api_version
      @version
    end

    def rooms
      {
        'v1' => {
          :base_uri => "#{@host}/v1/rooms",
          :url => '/list'
        },
        'v2' => {
          :base_uri => "#{@host}/v2",
          :url => '/room'
        }
      }[@version]
    end

    def send(room_id)
      {
        'v1' => {
          :base_uri => "#{@host}/v1/rooms",
          :url => "/message",
          :body_format => :to_h
        },
        'v2' => {
          :base_uri => "#{@host}/v2/room",
          :url => "/#{room_id}/notification",
          :body_format => :to_json
        }
      }[@version]
    end

    def topic(room_id)
      {
        'v1' => {
          :base_uri => "#{@host}/v1/rooms",
          :url => '/topic',
          :method => :post,
          :body_format => :to_h
        },
        'v2' => {
          :base_uri => "#{@host}/v2/room",
          :url => "/#{room_id}/topic",
          :method => :put,
          :body_format => :to_json
        }
      }[@version]
    end

    def history(room_id)
      {
        'v1' => {
          :base_uri => "#{@host}/v1/rooms",
          :url => '/history'
        },
        'v2' => {
          :base_uri => "#{@host}/v2/room",
          :url => "/#{room_id}/history"
        }
      }[@version]
    end

    def bool_val(opt)
      if @version.eql?('v1')
        opt ? 1 : 0
      else
        opt
      end
    end

  end
end
