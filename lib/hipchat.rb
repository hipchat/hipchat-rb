require 'httparty'
require 'ostruct'

module HipChat
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
    format :json

    def initialize(token, params)
      @token = token

      super(params)
    end

    def send(from, message, notify = false)
      self.class.post('/message',
           :query => { :auth_token => @token },
           :body => {
             :room_id => room_id,
             :from => from,
             :message => message,
             :notify => notify ? 1 : 0
           })
    end
  end
end
