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

    def initialize(api_token, room_name, excluded_envs=[], notify_users=false, report_success=false)
      @api_token = api_token
      @room_name = room_name
      @excluded_envs = excluded_envs
      @notify_users = notify_users
      @report_success = report_success
    end

    def report
      unless @excluded_envs.include?(node.chef_environment)
        msg = if run_status.failed? then "Failure on \"#{node.name}\" (\"#{node.chef_environment}\" env): #{run_status.formatted_exception}"
              elsif run_status.success? && @report_success
                "Chef run on \"#{node.name}\" completed in #{run_status.elapsed_time.round(2)} seconds"
              else nil
              end

        color = if run_status.success? then 'green'
                else 'red'
                end

        if msg
          client = HipChat::Client.new(@api_token)
          client[@room_name].send('Chef', msg, :notify => @notify_users, :color => color)
        end
      end
    end
  end
end
