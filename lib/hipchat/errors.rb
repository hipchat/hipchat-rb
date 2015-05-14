module HipChat
  class UnknownRoom         < StandardError; end
  class RoomNameTooLong     < StandardError; end
  class RoomMissingOwnerUserId < StandardError; end
  class Unauthorized        < StandardError; end
  class UsernameTooLong     < StandardError; end
  class UnknownResponseCode < StandardError; end
  class UnknownUser         < StandardError; end
  class InvalidApiVersion   < StandardError; end
  class InvalidUrl          < StandardError; end
  class InvalidEvent        < StandardError; end
  class UnknownWebhook      < StandardError; end
end
