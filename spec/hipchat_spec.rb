require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do
  subject { HipChat::Client.new("blah") }

  let(:room) { subject["Hipchat"] }

  # Helper for mocking room message post requests
  def mock_successful_send(from, message, options={})
    options = {:color => 'yellow', :notify => 0, :message_format => 'html'}.merge(options)
    mock(HipChat::Room).post("/message",
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => "Dude",
                                        :message => "Hello world",
                                        :message_format => options[:message_format],
                                        :color   => options[:color],
                                        :notify  => options[:notify]}) {
      OpenStruct.new(:code => 200)
    }
  end

  def mock_successful_topic_change(topic, options={})
    options = {:from => 'API'}.merge(options)
    mock(HipChat::Room).post("/topic",
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => options[:from],
                                        :topic   => "Nice topic" } ) {
      OpenStruct.new(:code => 200)
    }
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
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.topic "" }.should raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { room.topic "" }.should raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
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
      mock_successful_send 'Dude', 'Hello world', :notify => 1

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

    it "but fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      lambda { room.send "", "" }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end
end
