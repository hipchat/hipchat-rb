require 'httparty'
require 'ostruct'

module HipChat

  class User < OpenStruct
    include HTTParty
    include FileHelper

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
    def send(message, message_format='text')
      response = self.class.post(@api.send_config[:url],
                                 :query => { :auth_token => @token },
                                 :body => {
                                     :message => message,
                                     :message_format => message_format
                                 }.send(@api.send_config[:body_format]),
                                 :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :user, user_id, response
      true
    end

    #
    # Send a private file to user.
    #
    def send_file(message, file)
      response = self.class.post(@api.send_file_config[:url],
        :query => { :auth_token => @token },
        :body => file_body({ :message => message }.send(@api.send_config[:body_format]), file),
        :headers => file_body_headers(@api.headers)
      )

      ErrorHandler.response_code_to_exception_for :user, user_id, response
      true
    end

    #
    # Get a user's details.
    #
    def view
      response = self.class.get(@api.view_config[:url],
                                :query => { :auth_token => @token }.merge(@api.view_config[:query_params]),
                                :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :user, user_id, response
      User.new(@token, response.merge(:api_version => @api.version))
    end

    #
    # Get private message history
    #
    def history(params = {})
      params.select! { |key, _value| @api.history_config[:allowed_params].include? key }

      response = self.class.get(@api.history_config[:url],
                                :query => { :auth_token => @token }.merge(params),
                                :headers => @api.headers
      )

      ErrorHandler.response_code_to_exception_for :user, user_id, response
      response.body
    end

    #
    # Get private message history
    #
    def delete(params = {})
      case @api.version
      when 'v1'
        response = self.class.post(@api.delete_config[:url],
                                  :query => { :auth_token => @token }.merge(params),
                                  :headers => @api.headers
        )
      when 'v2'
        response = self.class.delete(@api.delete_config[:url],
                                  :query => { :auth_token => @token },
                                  :headers => @api.headers
        )
      end

      ErrorHandler.response_code_to_exception_for :user, user_id, response
      true
    end

  end
end
