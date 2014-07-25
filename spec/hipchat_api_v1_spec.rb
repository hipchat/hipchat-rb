require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HipChat (API V1)" do

  subject { HipChat::Client.new("blah", :api_version => @api_version) }

  let(:room) { subject["Hipchat"] }

  describe "#history" do
    include_context "HipChatV1"
    it "is successful without custom options" do
      mock_successful_history()

      room.history().should be_true
    end

    it "is successful with custom options" do
      mock_successful_history(:timezone => 'America/Los_Angeles', :date => '2010-11-19')
      room.history(:timezone => 'America/Los_Angeles', :date => '2010-11-19').should be_true
    end

    it "is successful from fetched room" do
      mock_successful_rooms
      mock_successful_history

      subject.rooms.should be_true
      subject.rooms.first.history.should be_true
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
    include_context "HipChatV1"
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

  describe "#send" do
    include_context "HipChatV1"
    it "successfully without custom options" do
      mock_successful_send 'Dude', 'Hello world'

      room.send("Dude", "Hello world").should be_true
    end

    it "successfully with notifications on as option" do
      mock_successful_send 'Dude', 'Hello world', :notify => 1

      room.send("Dude", "Hello world", :notify => 1).should be_true
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

  describe "#create" do
    include_context "HipChatV1"

    it "successfully with room name" do
      mock_successful_room_creation("A Room", :owner_user_id => "123456")

      subject.create_room("A Room", {:owner_user_id => "123456"}).should be_true
    end

    it "successfully with custom parameters" do
      mock_successful_room_creation("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access => "1"})

      subject.create_room("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access =>true}).should be_true
    end

    it "but fails if we dont pass owner_user_id" do
      lambda { subject.create_room("A Room", {:privacy => "private", :guest_access =>true}) }.
        should raise_error(HipChat::RoomMissingOwnerUserId)
    end
  end

  describe "#send user message" do
    it "fails because API V1 doesn't support user operations" do

      lambda { HipChat::Client.new("blah", :api_version => @api_version).user('12345678') }.
        should raise_error(HipChat::InvalidApiVersion)
    end
  end
end
