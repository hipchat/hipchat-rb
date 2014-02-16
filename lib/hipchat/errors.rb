module HipChat
  class UnknownRoom         < StandardError; end
  class RoomNameTooLong     < StandardError; end
  class Unauthorized        < StandardError; end
  class UsernameTooLong     < StandardError; end
  class UnknownResponseCode < StandardError; end
end