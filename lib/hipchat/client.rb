require 'hipchat/api_version'

module HipChat

  class Client
    include HTTParty

    format :json

    def initialize(token, options={})
      @token = token
      default_options = { api_version: 'v1', server_url: 'https://api.hipchat.com' }
      @options = default_options.merge options
      @api_version = options[:api_version]
      @api = HipChat::ApiVersion::Client.new(@options)
      self.class.base_uri(@api.base_uri)
      http_proxy = options[:http_proxy] || ENV['http_proxy']
      setup_proxy(http_proxy) if http_proxy
    end

    def rooms
      @rooms ||= _rooms
    end

    def [](name)
      Room.new(@token, { room_id: name }.merge(@options))
    end

    def create_user(name, options={})
      response = self.class.post(@api.create_user_config[:url],
        :query => { :auth_token => @token },
        :body => {
          :name => name,
          :email => options[:email]
          }.merge(options).send(@api.create_user_config[:body_format]),
        :headers => @api.headers
      )

      case response.code
      when 201, 200 #CREATED
        response.parsed_response
      when 400
        raise UnknownUser,  "Error: #{response.message}"
      when 401
        raise Unauthorized, "Access denied"
      else
        raise UnknownResponseCode, "Unexpected error #{response.code}"
      end
    end

    def create_room(name, options={})
      if @api.version == 'v1' && options[:owner_user_id].nil?
        raise RoomMissingOwnerUserId, "V1 API Requires owner_user_id"
      end
      if name.length > 50
        raise RoomNameTooLong, "Room name #{name} is #{name.length} characters long. Limit is 50."
      end
      unless options[:guest_access].nil?
        options[:guest_access] = @api.bool_val(options[:guest_access])
      end

      response = self.class.post(@api.create_room_config[:url],
        :query => { :auth_token => @token },
        :body => {
          :name => name
          }.merge(options).send(@api.create_room_config[:body_format]),
        :headers => @api.headers
      )

      case response.code
      when 201, 200 #CREATED
        response.parsed_response
      when 400
        raise UnknownRoom,  "Error: #{response.message}"
      when 401
        raise Unauthorized, "Access denied"
      else
        raise UnknownResponseCode, "Unexpected error #{response.code}"
      end
    end

    def user(name)
      User.new(@token, { :user_id => name }.merge(@options))
    end

    def users
      @users ||= _users
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
          Room.new(@token, r.merge(:api_version => @api_version, :room_id => r['id'], :server_url => @options[:server_url]))
        end
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room"
      end
    end

    def _users
      response = self.class.get(@api.users_config[:url],
        :query => {
          :auth_token => @token,
          :expand => 'items'
        },
        :headers => @api.headers
      )
      case response.code
      when 200
        response[@api.users_config[:data_key]].map do |r|
          User.new(@token, r.merge(:api_version => @api_version, :user_id => r['id']))
        end
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for room"
      end
    end
  end
end
