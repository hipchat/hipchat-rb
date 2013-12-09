require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do
  subject { HipChat::Client.new("blah") }

  let(:room) { subject["Hipchat"] }

  # Helper for mocking room message post requests
  def mock_successful_send(from, message, options={})
    options = {:color => 'yellow', :notify => false, :message_format => 'html'}.merge(options)
    mock(HipChat::Room).post("/Hipchat/notification",
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => "Dude",
                                        :message => "Hello world",
                                        :message_format => options[:message_format],
                                        :color   => options[:color],
                                        :notify  => options[:notify]}.to_json) {
      OpenStruct.new(:code => 200)
    }
  end

  def mock_successful_topic_change(topic, options={})
    options = {:from => 'API'}.merge(options)
    mock(HipChat::Room).put("/Hipchat/topic",
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => options[:from],
                                        :topic   => "Nice topic" }.to_json ) {
      OpenStruct.new(:code => 200)
    }
  end

  def mock_successful_history(options={})
    options = { :date => 'recent', :timezone => 'UTC', :format => 'JSON' }.merge(options)
    canned_response = File.new File.expand_path(File.dirname(__FILE__) + '/example/history.json')
    stub_request(:get, "https://api.hipchat.com/v2/room/Hipchat/history").with(:query => {:auth_token => "blah",
                                   :room_id    => "Hipchat",
                                   :date       => options[:date],
                                   :timezone   => options[:timezone],
                                   :format     => options[:format]}).to_return(canned_response)
  end

  describe "#history" do
    it "is successful without custom options" do
      mock_successful_history()

      room.history().should be_true
    end

    it "is successful with custom options" do
      mock_successful_history(:timezone => 'America/Los_Angeles', :date => '2010-11-19')
      room.history(:timezone => 'America/Los_Angeles', :date => '2010-11-19').should be_true
    end

    it "fails when the room doen't exist" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.history }.should raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { room.history }.should raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      lambda { room.history }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#topic" do
    it "is successful without custom options" do
      mock_successful_topic_change("Nice topic")

      room.topic("Nice topic").should be_true
    end

    it "is successful with a custom from" do
      mock_successful_topic_change("Nice topic", :from => "Me")

      room.topic("Nice topic", :from => "Me").should be_true
    end

    it "fails when the room doesn't exist" do
      mock(HipChat::Room).put(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.topic "" }.should raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).put(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { room.topic "" }.should raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).put(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      lambda { room.topic "" }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "sends a message to a room" do
    it "successfully without custom options" do
      mock_successful_send 'Dude', 'Hello world'

      room.send("Dude", "Hello world").should be_true
    end

    it "successfully with notifications on as option" do
      mock_successful_send 'Dude', 'Hello world', :notify => true

      room.send("Dude", "Hello world", :notify => true).should be_true
    end

    it "successfully with custom color" do
      mock_successful_send 'Dude', 'Hello world', :color => 'red'

      room.send("Dude", "Hello world", :color => 'red').should be_true
    end

    it "successfully with text message_format" do
      mock_successful_send 'Dude', 'Hello world', :message_format => 'text'

      room.send("Dude", "Hello world", :message_format => 'text').should be_true
    end

    it "but fails when the room doesn't exist" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.send "", "" }.should raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { room.send "", "" }.should raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      lambda { room.send "a very long username here", "a message" }.should raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      lambda { room.send "", "" }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe 'http_proxy' do
    let(:proxy_user) { 'proxy_user' }
    let(:proxy_pass) { 'proxy_pass' }
    let(:proxy_host) { 'proxy.example.com' }
    let(:proxy_port) { 2649 }
    let(:proxy_url) { "http://#{proxy_user}:#{proxy_pass}@#{proxy_host}:#{proxy_port}" }

    context 'specified by option of constructor' do
      before do
        HipChat::Client.new("blah", :http_proxy => proxy_url)
      end

      subject { HipChat::Client.default_options }

      specify "Client's proxy settings should be changed" do
        expect(subject[:http_proxyaddr]).to eql(proxy_host)
        expect(subject[:http_proxyport]).to eql(proxy_port)
        expect(subject[:http_proxyuser]).to eql(proxy_user)
        expect(subject[:http_proxypass]).to eql(proxy_pass)
      end

      describe "Room class's proxy" do
        subject { HipChat::Room.default_options }

        specify "proxy settings should be changed" do
          expect(subject[:http_proxyaddr]).to eql(proxy_host)
          expect(subject[:http_proxyport]).to eql(proxy_port)
          expect(subject[:http_proxyuser]).to eql(proxy_user)
          expect(subject[:http_proxypass]).to eql(proxy_pass)
        end
      end
    end
  end
end
