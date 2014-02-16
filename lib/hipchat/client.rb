require 'hipchat/api_version'

module HipChat

  class Client
    include HTTParty

    format :json

    def initialize(token, options={})
      @token = token
      @api_version = options[:api_version]
      @api = HipChat::ApiVersion::Client.new(@api_version)
      self.class.base_uri(@api.base_uri)
      http_proxy = options[:http_proxy] || ENV['http_proxy']
      setup_proxy(http_proxy) if http_proxy
    end

    def rooms
      @rooms ||= _rooms
    end

    def [](name)
      Room.new(@token, :room_id => name, :api_version => @api_version)
    end

    def create_room(name, owner_user_id="", privacy='public', guest_access=false)
      if name.length > 50
        raise RoomNameTooLong, "Room name #{name} is #{name.length} characters long. Limit is 50."
      end

      response = self.class.post(@api.create_room_config[:url],
        :query => { :auth_token => @token },
        :body => {
          :name => name,
          :owner_user_id => owner_user_id,
          :privacy => privacy,
          :guest_access => guest_access
          }.to_json,
        :headers => @api.headers
      )

      case response.code
      when 201 #CREATED
        response.parsed_response["id"]
      when 400
        raise UnknownRoom,  "Error: #{response.message}"
      when 401
        raise Unauthorized, "Access denied"
      else
        raise UnknownResponseCode, "Unexpected errorres #{response.code}"
      end
    end

    private
    def setup_proxy(proxy_url)
      proxy_url = URI.parse(proxy_url)

      self.class.http_proxy(proxy_url.host, proxy_url.port,
                            proxy_url.user, proxy_url.password)
      HipChat::Room.http_proxy(proxy_url.host, proxy_url.port,
                               proxy_url.user, proxy_url.password)
    end

    def _rooms
      response = self.class.get(@api.rooms_config[:url],
        :query => {
          :auth_token => @token
        },
        :headers => @api.headers
      )
      case response.code
      when 200
        response[@api.rooms_config[:data_key]].map do |r|
          Room.new(@token, r.merge(:api_version => @api_version))
        end
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room"
      end
    end
  end
end