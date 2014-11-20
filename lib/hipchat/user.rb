require 'httparty'
require 'ostruct'

module HipChat

  class User < OpenStruct
    include HTTParty

    format :json

    def initialize(token, params)
      @token = token
      @api = HipChat::ApiVersion::User.new(params)
      self.class.base_uri(@api.base_uri)
      super(params)
    end

    #
    # Send a private message to user.
    #
    def send(message)
      response = self.class.post(@api.send_config[:url],
                                 :query => { :auth_token => @token },
                                 :body => {
                                     :message => message
                                 }.send(@api.send_config[:body_format]),
                                 :headers => @api.headers
      )

      case response.code
      when 200, 204;
        true
      when 404
        raise UnknownUser, "Unknown user: `#{user_id}'"
      when 401
        raise Unauthorized, "Access denied to user `#{user_id}'"
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for private message to `#{user_id}'"
      end
    end

    #
    # Get a user's details.
    #
    def view
      response = self.class.get(@api.view_config[:url],
                                :query => { :auth_token => @token }.merge(@api.view_config[:query_params]),
                                :headers => @api.headers
      )

      case response.code
      when 200
        User.new(@token, response.merge(:api_version => @api.version))
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for view message to `#{user_id}'"
      end
    end

    #
    # Get private message history
    #
    def history(params = {})
      params.select! { |key, _value| allowed_params.include? key }

      response = self.class.get(@api.history_config[:url],
                                :query => { :auth_token => @token }.merge(params),
                                :headers => @api.headers
      )

      case response.code
      when 200
        response.body
      else
        raise UnknownResponseCode, "Unexpected #{response.code} for view private message history for `#{user_id}'"
      end
    end
  end
end
