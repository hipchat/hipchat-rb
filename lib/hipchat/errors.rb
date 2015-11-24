module HipChat
  class ServiceError            < StandardError;  end
  class RoomNameTooLong         < ServiceError;   end
  class RoomMissingOwnerUserId  < ServiceError;   end
  class Unauthorized            < ServiceError;   end
  class BadRequest              < ServiceError;   end
  class MethodNotAllowed        < ServiceError;   end
  class UsernameTooLong         < ServiceError;   end
  class UnknownResponseCode     < ServiceError;   end
  class InvalidApiVersion       < ServiceError;   end
  class InvalidUrl              < ServiceError;   end
  class InvalidEvent            < ServiceError;   end
  class ObjectNotFound          < ServiceError;   end
  class UnknownRoom             < ObjectNotFound; end
  class UnknownUser             < ObjectNotFound; end
  class UnknownWebhook          < ObjectNotFound; end
  class TooManyRequests         < ServiceError;   end

  class ErrorHandler

    # Pass-through to catch error states and raise their appropriate exceptions
    # @param klass {Symbol} The class of object we are handling the error for
    # @param identifier {String} An identifying string for the object causing the error
    # @param response {HTTParty::Response} The HTTParty response/request object
    def self.catch_and_raise_exception_for(klass, identifier, response)
      not_found_exception = Module.const_get(HipChat.to_s.to_sym).const_get("Unknown#{klass.capitalize}".to_sym)
      case response.code
        when 200, 201, 202, 204;
          return
        when 400
          raise BadRequest, "The request was invalid. You may be missing a required argument or provided bad data. path:#{response.request.path.to_s} method:#{response.request.http_method.to_s}"
        when 401, 403
          raise Unauthorized, "Access denied to #{klass} `#{identifier}'"
        when 404
          raise not_found_exception,  "Unknown #{klass}: `#{identifier}'"
        when 405
          raise MethodNotAllowed, "You requested an invalid method. path:#{response.request.path.to_s} method:#{response.request.http_method.to_s}"
        when 429
          raise TooManyRequests, 'You have exceeded the rate limit. `https://www.hipchat.com/docs/apiv2/rate_limiting`'
        else
          raise UnknownResponseCode, "Unexpected #{response.code} for #{klass} `#{identifier}'"
      end
    end
  end

end
