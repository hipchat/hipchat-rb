module HipChat
  class UnknownRoom         < StandardError; end
  class Unauthorized        < StandardError; end
  class UsernameTooLong     < StandardError; end
  class UnknownResponseCode < StandardError; end
  class UnknownUser         < StandardError; end
  class InvalidApiVersion   < StandardError; end
  class UsernameInvalid     < StandardError; end
end