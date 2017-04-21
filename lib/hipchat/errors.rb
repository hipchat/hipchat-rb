module HipChat
  class ServiceError < StandardError
    attr_accessor :response

    def initialize(msg, response: nil)
      @response = response
      @msg = msg
    end

    def message
      if @response.present?
        "#{@msg}:\nResponse: #{@response.body}"
      else
        @msg
      end
    end
  end

  class RoomNameTooLong         < ServiceError;        end
  class RoomMissingOwnerUserId  < ServiceError;        end
  class UnknownResponseCode     < ServiceError;        end
  class Unauthorized            < UnknownResponseCode; end
  class BadRequest              < ServiceError;        end
  class MethodNotAllowed        < ServiceError;        end
  class UsernameTooLong         < ServiceError;        end
  class InvalidApiVersion       < ServiceError;        end
  class InvalidUrl              < ServiceError;        end
  class InvalidEvent            < ServiceError;        end
  class ObjectNotFound          < UnknownResponseCode; end
  class UnknownRoom             < ObjectNotFound;      end
  class UnknownUser             < ObjectNotFound;      end
  class UnknownWebhook          < ObjectNotFound;      end
  class TooManyRequests         < UnknownResponseCode; end

  class ErrorHandler

    # Pass-through to catch error states and raise their appropriate exceptions
    # @param klass {Symbol} The class of object we are handling the error for
    # @param identifier {String} An identifying string for the object causing the error
    # @param response {HTTParty::Response} The HTTParty response/request object
    def self.response_code_to_exception_for(klass, identifier, response)
      # Supports user, room and webhook objects.  If we get something other than that, bail.
      raise(ServiceError.new("Unknown class #{klass}", response: response)) unless [:user, :room, :webhook].include? klass
      # Grab the corresponding unknown object exception class and constantize it for the 404 case to call
      not_found_exception = Module.const_get(HipChat.to_s.to_sym).const_get("Unknown#{klass.capitalize}".to_sym)
      case response.code
        when 200, 201, 202, 204;
          return
        when 400
          raise BadRequest.new("The request was invalid. You may be missing a required argument or provided bad data. path:#{response.request.path} method:#{response.request.http_method}", response: response)
        when 401, 403
          raise Unauthorized.new("Access denied to #{klass} `#{identifier}'", response: response)
        when 404
          raise not_found_exception.new("Unknown #{klass}: `#{identifier}'", response: response)
        when 405
          raise MethodNotAllowed.new("You requested an invalid method. path:#{response.request.path} method:#{response.request.http_method}", response: response)
        when 429
          raise TooManyRequests.new('You have exceeded the rate limit. `https://www.hipchat.com/docs/apiv2/rate_limiting`', response: response)
        else
          raise UnknownResponseCode.new("Unexpected #{response.code} for #{klass} `#{identifier}'", response: response)
      end
    end
  end

end
