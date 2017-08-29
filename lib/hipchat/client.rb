module HipChat

  class Client
    include HTTParty

    format :json

    def initialize(token, options={})
      @token = token
      default_options = { api_version: 'v2', server_url: 'https://api.hipchat.com' }
      @options = default_options.merge options
      @api_version = @options[:api_version]
      @api = HipChat::ApiVersion::Client.new(@options)
      self.class.base_uri(@api.base_uri)
      http_proxy = @options[:http_proxy] || ENV['http_proxy']
      setup_proxy(http_proxy) if http_proxy
    end

    def rooms(options = {})
      @rooms ||= {}
      @rooms[options] ||= _rooms(options)
    end

    def [](name)
      HipChat::Room.new(@token, { room_id: name, :api_version => @api_version, :server_url => @options[:server_url] })
    end

    # Returns the scopes for the Auth token
    #
    # Calls the endpoint:
    #
    #   https://api.hipchat.com/v2/oauth/token/#{token}
    #
    #   The response is a JSON object containing a client key. The client
    #   object contains a list of allowed scopes.
    #
    #   There are two possible response types, for a global API token, the
    #   room object will be nil. For a room API token, the room object will
    #   be populated:
    #
    # Optional room parameter can be passed in. The method will return the
    # following:
    #
    #   - if it's a global API token and room param is nil: scopes
    #   - if it's a global API token and room param is not nil: scopes
    #   - if it's a room API token and room param is nil: nil
    #   - if it's a room API token and room param is not nil
    #       - if room param's room_id matches token room_id: scopes
    #       - if room param's room_id doesn't match token room_id: nil
    #
    # Raises errors if response is unrecognizable
    def scopes(room: nil)
      path = "#{@api.scopes_config[:url]}/#{URI::escape(@token)}"
      response = self.class.get(path,
        :query => { :auth_token => @token },
        :headers => @api.headers
      )
      ErrorHandler.response_code_to_exception_for :room, 'scopes', response
      return response['scopes'] unless response['client']['room']
      if room && response['client']['room']['id'] == room.room_id
        return response['scopes']
      end
    end

    def create_room(name, options={})
      if @api.version == 'v1' && options[:owner_user_id].nil?
        raise RoomMissingOwnerUserId, 'V1 API Requires owner_user_id'
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

      ErrorHandler.response_code_to_exception_for :room, name, response
      response.parsed_response
    end

    def create_user(name, email, options={})
      if name.length > 50
        raise UsernameTooLong, "User name #{name} is #{name.length} characters long. Limit is 50."
      end

      response = self.class.post(@api.create_user_config[:url],
        :query => { :auth_token => @token },
        :body => {
          :name => name,
          :email => email
          }.merge(options).send(@api.create_user_config[:body_format]),
        :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :user, email, response
      response.parsed_response
    end

    def user(name)
      HipChat::User.new(@token, { :user_id => name, :api_version => @api_version, :server_url => @options[:server_url] })
    end

    def users(options = {})
      @users ||= {}
      @users[options] ||= _users(options)
    end

    private

    def no_proxy?
      host = URI.parse(@options[:server_url]).host
      ENV.fetch('no_proxy','').split(',').any? do |pattern|
        # convert patterns like `*.example.com` into `.*\.example\.com`
        host =~ Regexp.new(pattern.gsub(/\./,'\\.').gsub(/\*/,'.*'))
      end
    end

    def setup_proxy(proxy_url)
      return if no_proxy?

      proxy_url = URI.parse(proxy_url)

      self.class.http_proxy(proxy_url.host, proxy_url.port,
                            proxy_url.user, proxy_url.password)
      HipChat::Room.http_proxy(proxy_url.host, proxy_url.port,
                               proxy_url.user, proxy_url.password)
    end

    def _rooms(options)
      wrapped_results(
        config:         @api.rooms_config,
        query_options:  options,
        error_key:      :user,
        wrapping_class: HipChat::Room
      )
    end

    def _users(options)
      wrapped_results(
        config:         @api.users_config,
        query_options:  { expand: 'items' }.merge(options),
        error_key:      :user,
        wrapping_class: HipChat::User
      )
    end

    def wrapped_results(options)
      config         = options.fetch(:config)
      query_options  = options.fetch(:query_options, {})
      error_key      = options.fetch(:error_key)
      wrapping_class = options.fetch(:wrapping_class)

      response = self.class.get(config[:url],
        query: {
          auth_token: @token,
        }.merge(query_options),
        headers: @api.headers
      )

      ErrorHandler.response_code_to_exception_for error_key, nil, response
      response[config[:data_key]].map do |u|
        wrapping_class.new(@token, u.merge(api_version: @api_version, server_url: @options[:server_url]))
      end
    end
  end
end
