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

    def initialize(api_token, room_name, options={}, msg_options={}, notify_users=false, report_success=false, excluded_envs=[], msg_prefix='')
      @api_token = api_token
      @room_name = room_name
      @options = options
      @report_success = report_success
      @msg_options = msg_options
      @msg_options[:notify] = notify_users 
      @msg_prefix = msg_prefix
      @excluded_envs = excluded_envs
    end

    def report
      unless @excluded_envs.include?(node.chef_environment)
        msg = if run_status.failed? then "Failure on \"#{node.name}\" (\"#{node.chef_environment}\" env): #{run_status.formatted_exception}"
              elsif run_status.success? && @report_success
                "Chef run on \"#{node.name}\" completed in #{run_status.elapsed_time.round(2)} seconds"
              else nil
              end

        @msg_options[:color]= if run_status.success? then 'green'
                else 'red'
                end

        if msg
          client = HipChat::Client.new(@api_token, @options)
          client[@room_name].send('Chef', [@msg_prefix, msg].join(' '), @msg_options)
        end
      end
    end
  end
end
