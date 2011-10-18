require 'httparty'
require 'ostruct'

require 'hipchat/railtie' if defined?(Rails::Railtie)

module HipChat
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UnknownResponseCode < StandardError; end

  class Client
    include HTTParty

    base_uri 'https://api.hipchat.com/v1/rooms'
    format :json

    def initialize(token)
      @token = token
    end

    def rooms
      @rooms ||= self.class.get("/list", :query => {:auth_token => @token})['rooms'].
        map { |r| Room.new(@token, r) }
    end

    def [](name)
      Room.new(@token, :room_id => name)
    end
  end

  class Room < OpenStruct
    include HTTParty

    base_uri 'https://api.hipchat.com/v1/rooms'

    def initialize(token, params)
      @token = token

      super(params)
    end

    # Send a message to this room.
    #
    # Usage:
    #
    #   send 'nickname', 'some message' 
    #   # => posts without notifying users and with default color (yellow)
    # 
    #   send 'nickname', 'some message', :notify => true, :color => 'red' 
    #   # => Posts notifying users and with color red
    #
    # Available options currently only are :color ("yellow", "red", "green", "purple", or "random") and
    # notify (true or false).
    #
    def send(from, message, options_or_notify = false)
      # The api used to only allow the notify users option, but other things like color should be 
      # available as parameters too.
      if options_or_notify == true or options_or_notify == false
        # warn "DEPRECATED: notify boolean flag has been replaced with room.send(nick, msg, :notify => true/false). Please update your code accordingly!"
        options = {:notify => options_or_notify }
      else
        # Make sure options are available as a hash at this stage, either from a hash given 
        # as argument or by initializing
        options = options_or_notify || {}
      end
      # Merge in default options
      options = {:color => 'yellow', :notify => false}.merge(options)
      
      response = self.class.post('/message',
                                 :query => { :auth_token => @token },
                                 :body => {:room_id => room_id,
                                           :from => from,
                                           :message => message,
                                           :color => options[:color],
                                           :notify => options[:notify] ? 1 : 0})

      case response.code
      when 200; true
      when 404; raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401; raise Unauthorized, "Access denied to room `#{room_id}'"
      else      raise UnknownResponseCode, "Unexpected #{response.code} for " <<
                                           "room `#{room_id}'"

      end
    end
  end
end
