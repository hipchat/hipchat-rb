module HipChat
  class ServiceError        < StandardError; end
  class UnknownRoom         < ServiceError; end
  class RoomNameTooLong     < ServiceError; end
  class RoomMissingOwnerUserId < ServiceError; end
  class Unauthorized        < ServiceError; end
  class UsernameTooLong     < ServiceError; end
  class UnknownResponseCode < ServiceError; end
  class UnknownUser         < ServiceError; end
  class InvalidApiVersion   < ServiceError; end
  class InvalidUrl          < ServiceError; end
  class InvalidEvent        < ServiceError; end
  class UnknownWebhook      < ServiceError; end
end
