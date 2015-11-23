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
end
