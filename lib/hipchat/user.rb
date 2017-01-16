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
    def send(message, options = {})
      message_format = options[:message_format] ? options[:message_format] : 'text'
      notify         = options[:notify]         ? options[:notify]         : false

      response = self.class.post(@api.send_config[:url],
                                 :query => { :auth_token => @token },
                                 :body => {
                                     :message => message,
                                     :message_format => message_format,
                                     :notify => notify
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

    #
    # User update.
    # API: https://www.hipchat.com/docs/apiv2/method/update_user
    # Request body
    # name - REQUIRED - User's full name.  Valid length range: 1-50
    # roles - The list of roles for the user. For example "owner", "administrator", "user", "delegated administrator"
    # title - User's title
    # status - string may be null
    # show - REQUIRED -  string - the status to show for the user. Available options 'away', 'chat', 'dnd', 'xa'
    # mention_name - REQUIRED - User's @mention name without the @
    # is_group_admin - Whether or not this user is an administrator
    # timezone - User's timezone. Must be a supported timezone.  Defaults to 'UTC'
    # password - User's password.  If not provided, the existing password is kept
    # email - REQUIRED - User's email
    def update(message, options = {})
      name          = options[:name]    
      roles         = options[:roles]   ? options[:roles] : nil
      title         = options[:title]   ? options[:title] : nil
      status        = options[:status]  ? options[:status] : nil
      show          = options[:show]    ? options[:show] : nil 
      mention_name  = options[:mention_name] 
      is_group_admin = options[:is_group_admin] ? options[:is_group_admin] : nil
      timezone      = options[:timeszone] ? options[:timezone] : 'UTC'
      password      = options[:password] ? options[:password] : nil
      email         = options[:email] 

      #create body format
      body = {
        
      }


      response = self.class.put(@api.user_update_config[:url],
                                 :query => { :auth_token => @token },
                                 :body => {
                                     :name            => name,
                                     :presence        => {:status=>status, :show=>show},
                                     :mention_name    => mention_name,
                                     :timezone        => timezone,
                                     :email           => email
                                 }
                                 .merge(title ? {:title =>title} : {})
                                 .merge(password ? {:password => password} : {})
                                 .merge(is_group_admin ? {:is_group_admin => is_group_admin} : {})
                                 .merge(roles ? {:roles => roles} : {})
                                 .send(@api.user_update_config[:body_format]),
                                 :headers => @api.headers
      )
      
      ErrorHandler.response_code_to_exception_for :user, user_id, response
    end

  end
end
