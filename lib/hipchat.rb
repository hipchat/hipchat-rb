require 'httparty'
require 'ostruct'

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

    def send(from, message, notify = false)
      response = self.class.post('/message',
                                 :query => { :auth_token => @token },
                                 :body => {:room_id => room_id,
                                           :from => from,
                                           :message => message,
                                           :notify => notify ? 1 : 0})

      case response.code
      when 200; # weee
      when 404; raise UnknownRoom,  "Unknown room: `#{room_id}'"
      when 401; raise Unauthorized, "Access denied to room `#{room_id}'"
      else      raise UnknownResponseCode, "Unexpected #{response.code} for " <<
                                           "room `#{room_id}'"

      end
    end
  end
end
