require 'hipchat'

#
# Provides a Chef exception handler so you can send information about
# chef-client failures to a HipChat room.
#
# Docs: http://wiki.opscode.com/display/chef/Exception+and+Report+Handlers
#
# Install - add the following to your client.rb:
#   require 'hipchat/chef'
#   hipchat_handler = HipChat::NotifyRoom.new("<api token>", "<room name>")
#   exception_handlers << hipchat_handler
#

module HipChat
  class NotifyRoom < Chef::Handler

    def initialize(api_token, room_name, notify_users=false)
      @api_token = api_token
      @room_name = room_name
      @notify_users = notify_users
    end

    def report
      msg = "Failure on #{node.name}: #{run_status.formatted_exception}"

      client = HipChat::Client.new(@api_token)
      client[@room_name].send('Chef', msg, :notify => @notify_users)
    end
  end
end
