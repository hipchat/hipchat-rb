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

  def mock_successful_rooms
    stub_request(:get, "https://api.hipchat.com/v1/rooms/list").with(
                             :query => {:auth_token => "blah"},
                             :body => "",
                             :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(
                                            :status => 200,
                                            :body => '{"rooms":[{"room_id": "Hipchat", "links": {"self": "https://api.hipchat.com/v2/room/12345"}}]}',
                                            :headers => {})
  end

  def mock_successful_history(options={})
    options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON', :'max-results' => 100, :'start-index' => 0 }.merge(options)
    canned_response = File.new(HISTORY_JSON_PATH)
    stub_request(:get, "https://api.hipchat.com/v1/rooms/history").with(:query => {:auth_token => "blah",
                                   :room_id       => "Hipchat",
                                   :date          => options[:date],
                                   :timezone      => options[:timezone],
                                   :'max-results' => options[:'max-results'],
                                   :'start-index' => options[:'start-index'],
                                   :format        => options[:format]}).to_return(canned_response)
  end

  def mock_successful_room_creation(name, options={})
    options = {:name => "A Room"}.merge(options)
    stub_request(:post, "https://api.hipchat.com/v1/rooms/create").with(
                             :query => {:auth_token => "blah"},
                             :body  => { :name => name }.merge(options),
                             :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(
                                          :status => 200,
                                          :body => '{"room": {"room_id": "1234", "name" : "A Room"}}',
                                          :headers => {})
  end
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

  def mock_successful_file_send(from, message, file)
    stub_request(:post, "https://api.hipchat.com/v2/room/Hipchat/share/file").with(
                             :query => {:auth_token => "blah"},
                             :body  => "--sendfileboundary\nContent-Type: application/json; charset=UTF-8\nContent-Disposition: attachment; name=\"metadata\"\n\n{\"room_id\":\"Hipchat\",\"from\":\"Dude\",\"message\":\"Hello world\"}\n--sendfileboundary\nContent-Type: ; charset=UTF-8\nContent-Transfer-Encoding: base64\nContent-Disposition: attachment; name=\"file\"; filename=\"#{File.basename(file.path)}\"\n\ndGhlIGNvbnRlbnQ=\n\n--sendfileboundary--",
                             :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'multipart/related; boundary=sendfileboundary'}).to_return(:status => 200, :body => "", :headers => {})
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

  def mock_successful_rooms
    stub_request(:get, "https://api.hipchat.com/v2/room").with(
                             :query => {:auth_token => "blah"},
                             :body => "",
                             :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/json'}).to_return(
                                            :status => 200,
                                            :body => '{"items":[{"id": "Hipchat", "links": {"self": "https://api.hipchat.com/v2/room/12345"}}]}',
                                            :headers => {})
  end

  def mock_successful_history(options={})
    options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON', :'max-results' => 100, :'start-index' => 0 }.merge(options)
    canned_response = File.new(HISTORY_JSON_PATH)
    stub_request(:get, "https://api.hipchat.com/v2/room/Hipchat/history").with(:query => {:auth_token => "blah",
                                   :room_id    => "Hipchat",
                                   :date       => options[:date],
                                   :timezone   => options[:timezone],
                                   :'max-results' => options[:'max-results'],
                                   :'start-index' => options[:'start-index'],
                                   :format     => options[:format]}).to_return(canned_response)
  end

  def mock_successful_statistics(options={})
    stub_request(:get, "https://api.hipchat.com/v2/room/Hipchat/statistics").with(:query => {:auth_token => "blah",
                                   :room_id    => "Hipchat",
                                   :date       => options[:date],
                                   :timezone   => options[:timezone],
                                   :format     => options[:format]}).to_return(
                                          :status => 200,
                                          :body => '{"last_active": "2014-09-02T21:33:54+00:00", "links": {"self": "https://api.hipchat.com/v2/room/12345/statistics"},  "messages_sent": 10}',
                                          :headers => {})
  end

  def mock_successful_room_creation(name, options={})
    stub_request(:post, "https://api.hipchat.com/v2/room").with(
                             :query => {:auth_token => "blah"},
                             :body  => { :name => name }.merge(options).to_json,
                             :headers => {'Accept' => 'application/json',
                                          'Content-Type' => 'application/json'}).to_return(
                                          :status => 201,
                                          :body => '{"id": "12345", "links": {"self": "https://api.hipchat.com/v2/room/12345"}}',
                                          :headers => {})
  end

  def mock_successful_get_room(room_id="1234")
    stub_request(:get, "https://api.hipchat.com/v2/room/#{room_id}").with(
      :query => {:auth_token => "blah"},
      :body => "",
      :headers => {'Accept' => 'application/json',
                   'Content-Type' => 'application/json'}).to_return(:status => 200, :body => "{\"id\":\"#{room_id}\"}", :headers => {})
  end

  def mock_successful_update_room(room_id="1234", options={})
    stub_request(:put, "https://api.hipchat.com/v2/room/#{room_id}").with(
      :query => {:auth_token => "blah"},
      :body => {
        :name => "hipchat",
        :topic => "hipchat topic",
        :privacy => "public",
        :is_archived => false,
        :is_guest_accessible => false,
        :owner => { :id => "12345" }
      }.to_json,
      :headers => {"Accept" => "application/json",
                    "Content-Type" => "application/json"}).to_return(
                    :status => 204,
                    :body => "",
                    :headers => {})
  end

  def mock_successful_invite(options={})
    options = {:user_id => "1234"}.merge(options)
    stub_request(:post, "https://api.hipchat.com/v2/room/Hipchat/invite/#{options[:user_id]}").with(
      :query => {:auth_token => "blah"},
      :body  => {
        :reason => options[:reason]||""
      }.to_json,
      :headers => {'Accept' => 'application/json',
                   'Content-Type' => 'application/json'}).to_return(
                   :status => 204,
                   :body => "",
                   :headers => {})
  end

  def mock_successful_user_send(message)
    stub_request(:post, "https://api.hipchat.com/v2/user/12345678/message").with(
                                   :query   => {:auth_token => "blah"},
                                   :body    => {:message => "Equal bytes for everyone",
                                                :message_format => "text"},
                                   :headers => {'Accept' => 'application/json',
                                                'Content-Type' => 'application/json'}).to_return(:status => 200, :body => "", :headers => {})
  end

  def mock_successful_user_history()
    canned_response = File.new(HISTORY_JSON_PATH)
    url = 'https://api.hipchat.com/v2/user/12345678/history/latest'
    stub_request(:get, url).with(:query => { :auth_token => "blah" },
                                 :headers => { 'Accept' => 'application/json',
                                              'Content-Type' => 'application/json' }).to_return(canned_response)
  end

  def mock_successful_user_send_file(message, file)
    stub_request(:post, "https://api.hipchat.com/v2/user/12345678/share/file").with(
                                   :query   => {:auth_token => "blah"},
                                   :body    => "--sendfileboundary\nContent-Type: application/json; charset=UTF-8\nContent-Disposition: attachment; name=\"metadata\"\n\n{\"message\":\"Equal bytes for everyone\"}\n--sendfileboundary\nContent-Type: ; charset=UTF-8\nContent-Transfer-Encoding: base64\nContent-Disposition: attachment; name=\"file\"; filename=\"#{File.basename(file)}\"\n\ndGhlIGNvbnRlbnQ=\n\n--sendfileboundary--",
                                   :headers => {'Accept' => 'application/json',
                                                'Content-Type' => 'multipart/related; boundary=sendfileboundary'}).to_return(:status => 200, :body => "", :headers => {})
  end
end
