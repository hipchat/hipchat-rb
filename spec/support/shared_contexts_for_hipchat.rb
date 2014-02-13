HISTORY_JSON_PATH = File.expand_path(File.dirname(__FILE__) + '/../example/history.json')

shared_context "HipChatV1" do
  before { @api_version = 'v1'}
  # Helper for mocking room message post requests
  def mock_successful_send(from, message, options={})
    options = {:color => 'yellow', :notify => 0, :message_format => 'html'}.merge(options)
    stub_request(:post, "https://api.hipchat.com/v1/rooms/message").with(
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => "Dude",
                                        :message => "Hello world",
                                        :message_format => options[:message_format],
                                        :color   => options[:color],
                                        :notify  => "#{options[:notify]}"},
                              :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(:status => 200, :body => "", :headers => {})

  end

  def mock_successful_topic_change(topic, options={})
    options = {:from => 'API'}.merge(options)
    stub_request(:post, "https://api.hipchat.com/v1/rooms/topic").with(
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => options[:from],
                                        :topic   => "Nice topic" },
                              :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(:status => 200, :body => "", :headers => {})
  end

  def mock_successful_history(options={})
    options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON' }.merge(options)
    canned_response = File.new(HISTORY_JSON_PATH)
    stub_request(:get, "https://api.hipchat.com/v1/rooms/history").with(:query => {:auth_token => "blah",
                                   :room_id    => "Hipchat",
                                   :date       => options[:date],
                                   :timezone   => options[:timezone],
                                   :format     => options[:format]}).to_return(canned_response)
  end
  subject { HipChat::Client.new("blah", :api_version => @api_version) }
  let(:room) { subject["Hipchat"] }
end

shared_context "HipChatV2" do
  before { @api_version = 'v2'}
  # Helper for mocking room message post requests
  def mock_successful_send(from, message, options={})
    options = {:color => 'yellow', :notify => false, :message_format => 'html'}.merge(options)
    stub_request(:post, "https://api.hipchat.com/v2/room/Hipchat/notification").with(
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => "Dude",
                                        :message => "Hello world",
                                        :message_format => options[:message_format],
                                        :color   => options[:color],
                                        :notify  => options[:notify]}.to_json,
                                        :headers => {'Accept' => 'application/json',
                                                    'Content-Type' => 'application/json'}).to_return(:status => 200, :body => "", :headers => {})
  end

  def mock_successful_topic_change(topic, options={})
    options = {:from => 'API'}.merge(options)
    stub_request(:put, "https://api.hipchat.com/v2/room/Hipchat/topic").with(
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => options[:from],
                                        :topic   => "Nice topic" }.to_json,
                                        :headers => {'Accept' => 'application/json',
                                                    'Content-Type' => 'application/json'}).to_return(:status => 200, :body => "", :headers => {})
  end

  def mock_successful_history(options={})
    options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON' }.merge(options)
    canned_response = File.new(HISTORY_JSON_PATH)
    stub_request(:get, "https://api.hipchat.com/v2/room/Hipchat/history").with(:query => {:auth_token => "blah",
                                   :room_id    => "Hipchat",
                                   :date       => options[:date],
                                   :timezone   => options[:timezone],
                                   :format     => options[:format]}).to_return(canned_response)
  end

  def mock_successful_room_create(name,options={})
    stub_request(:put, "https://api.hipchat.com/v2/room").with(:query => {:auth_token =>"blah",
                                    :name         => name,
                                    :guest_access => options[:guest_access] || 'false',
                                    :privacy      => options[:privacy] })
    
  end
end