require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HipChat (API V1)" do

  subject { HipChat::Client.new("blah", :api_version => @api_version) }

  let(:room) { subject["Hipchat"] }

  describe "#history" do
    include_context "HipChatV1"
    it "is successful without custom options" do
      mock_successful_history()

      expect(room.history()).to be_truthy
    end

    it "is successful with custom options" do
      mock_successful_history(:timezone => 'America/Los_Angeles', :date => '2010-11-19', :'max-results' => 10, :'start-index' => 10)
      expect(room.history(:timezone => 'America/Los_Angeles', :date => '2010-11-19', :'max-results' => 10, :'start-index' => 10)).to be_truthy
    end

    it "is successful from fetched room" do
      mock_successful_rooms
      mock_successful_history

      expect(subject.rooms).to be_truthy
      expect(subject.rooms.first.history).to be_truthy
    end

    it "fails when the room doen't exist" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { room.history }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      expect { room.history }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      expect { room.history }.to raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#topic" do
    include_context "HipChatV1"
    it "is successful without custom options" do
      mock_successful_topic_change("Nice topic")

      expect(room.topic("Nice topic")).to be_truthy
    end

    it "is successful with a custom from" do
      mock_successful_topic_change("Nice topic", :from => "Me")

      expect(room.topic("Nice topic", :from => "Me")).to be_truthy
    end

    it "fails when the room doesn't exist" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { room.topic "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      expect { room.topic "" }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      expect { room.topic "" }.to raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#send" do
    include_context "HipChatV1"
    it "successfully without custom options" do
      mock_successful_send 'Dude', 'Hello world'

      expect(room.send("Dude", "Hello world")).to be_truthy
    end

    it "successfully with notifications on as option" do
      mock_successful_send 'Dude', 'Hello world', :notify => 1

      expect(room.send("Dude", "Hello world", :notify => 1)).to be_truthy
    end

    it "successfully with custom color" do
      mock_successful_send 'Dude', 'Hello world', :color => 'red'

      expect(room.send("Dude", "Hello world", :color => 'red')).to be_truthy
    end

    it "successfully with text message_format" do
      mock_successful_send 'Dude', 'Hello world', :message_format => 'text'

      expect(room.send("Dude", "Hello world", :message_format => 'text')).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { room.send "", "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      expect { room.send "", "" }.to raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      expect { room.send "a very long username here", "a message" }.to raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      expect { room.send "", "" }.to raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#create" do
    include_context "HipChatV1"

    it "successfully with room name" do
      mock_successful_room_creation("A Room", :owner_user_id => "123456")

      expect(subject.create_room("A Room", {:owner_user_id => "123456"})).to be_truthy
    end

    it "successfully with custom parameters" do
      mock_successful_room_creation("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access => "1"})

      expect(subject.create_room("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access =>true})).to be_truthy
    end

    it "but fails if we dont pass owner_user_id" do
      expect { subject.create_room("A Room", {:privacy => "private", :guest_access =>true}) }.to raise_error(HipChat::RoomMissingOwnerUserId)
    end
  end

  describe "#send user message" do
    it "fails because API V1 doesn't support user operations" do

      expect { HipChat::Client.new("blah", :api_version => @api_version).user('12345678').send('nope') }.
        to raise_error(HipChat::InvalidApiVersion)
    end
  end
end
