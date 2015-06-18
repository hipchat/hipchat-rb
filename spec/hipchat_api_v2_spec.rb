require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HipChat (API V2)" do

  subject { HipChat::Client.new("blah", :api_version => @api_version) }

  let(:room) { subject["Hipchat"] }
  let(:user) { subject.user "12345678" }

  describe "#history" do
    include_context "HipChatV2"
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

  describe "#statistics" do
    include_context "HipChatV2"
    it "is successful without custom options" do
      mock_successful_statistics

      expect(room.statistics()).to be_truthy
    end

    it "is successful from fetched room" do
      mock_successful_rooms
      mock_successful_statistics

      expect(subject.rooms).to be_truthy
      expect(subject.rooms.first.statistics).to be_truthy
    end

    it "fails when the room doen't exist" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { room.statistics }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      expect { room.statistics }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      mock(HipChat::Room).get(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      expect { room.statistics }.to raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#topic" do
    include_context "HipChatV2"
    it "is successful without custom options" do
      mock_successful_topic_change("Nice topic")

      expect(room.topic("Nice topic")).to be_truthy
    end

    it "is successful with a custom from" do
      mock_successful_topic_change("Nice topic", :from => "Me")

      expect(room.topic("Nice topic", :from => "Me")).to be_truthy
    end

    it "fails when the room doesn't exist" do
      mock(HipChat::Room).put(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { room.topic "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
        mock(HipChat::Room).put(anything, anything) {
          OpenStruct.new(:code => 401)
        }

      expect { room.topic "" }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
        mock(HipChat::Room).put(anything, anything) {
          OpenStruct.new(:code => 403)
        }

      expect { room.topic "" }.to raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#send" do
    include_context "HipChatV2"
    it "successfully without custom options" do
      mock_successful_send 'Dude', 'Hello world'

      expect(room.send("Dude", "Hello world")).to be_truthy
    end

    it "successfully with notifications on as option" do
      mock_successful_send 'Dude', 'Hello world', :notify => true

      expect(room.send("Dude", "Hello world", :notify => true)).to be_truthy
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

  describe "#send_file" do
    let(:file) do
      Tempfile.new('foo').tap do |f|
        f.write("the content")
        f.rewind
      end
    end

    after { file.unlink }

    include_context "HipChatV2"

    it "successfully" do
      mock_successful_file_send 'Dude', 'Hello world', file

      room.send_file("Dude", "Hello world", file).should be_truthy
    end

    it "but fails when the room doesn't exist" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.send_file "", "", file }.should raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { room.send_file "", "", file }.should raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      lambda { room.send_file "a very long username here", "a message", file }.should raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 403)
      }

      lambda { room.send_file "", "", file }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end

  describe "#create" do
    include_context "HipChatV2"

    it "successfully with room name" do
      mock_successful_room_creation("A Room")

      expect(subject.create_room("A Room")).to be_truthy
    end

    it "successfully with custom parameters" do
      mock_successful_room_creation("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access => true})

      expect(subject.create_room("A Room", {:owner_user_id => "123456", :privacy => "private", :guest_access =>true})).to be_truthy
    end

    it "but fail is name is longer then 50 char" do
      expect { subject.create_room("A Room that is too long that I should fail right now") }.
        to raise_error(HipChat::RoomNameTooLong)
    end
  end

  describe "#get_room" do
    include_context "HipChatV2"

    it "successfully" do
      mock_successful_get_room("Hipchat")

      expect(room.get_room).to be_truthy
    end

  end

  describe "#update_room" do
    include_context "HipChatV2"
    let(:room_info) {
      {
        "name" => "hipchat",
        "topic" => "hipchat topic",
        "privacy" => "public",
        "is_archived" => false,
        "is_guest_accessible" => false,
        "owner" => { "id" => "12345" }
      }
    }
    it "successfully" do
      mock_successful_update_room("Hipchat", room_info)
      expect(room.update_room(room_info)).to be_truthy
    end
  end

  describe "#invite" do
    include_context "HipChatV2"

    it "successfully with user_id" do
      mock_successful_invite()

      expect(room.invite("1234")).to be_truthy
    end

    it "successfully with custom parameters" do
      mock_successful_invite({:user_id => "321", :reason => "A great reason"})

      expect(room.invite("321", "A great reason")).to be_truthy
    end
  end

  describe "#send user message" do
    include_context "HipChatV2"
    it "successfully with a standard message" do
      mock_successful_user_send 'Equal bytes for everyone'

      expect(user.send('Equal bytes for everyone')).to be_truthy
    end

    it "but fails when the user doesn't exist" do
      mock(HipChat::User).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      expect { user.send "" }.to raise_error(HipChat::UnknownUser)
    end

    it "but fails when we're not allowed to do so" do
      mock(HipChat::User).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      expect { user.send "" }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#get_user_history' do
    include_context 'HipChatV2'

    it 'successfully returns history' do
      mock_successful_user_history
      user.history.should be_truthy
    end

    it 'has allowed params' do
      expect(user.instance_variable_get(:@api).history_config[:allowed_params]).to eq([:'max-results', :timezone, :'not-before'])
    end
  end

  describe "#send_file user" do
    include_context "HipChatV2"

    let(:file) do
      Tempfile.new('foo').tap do |f|
        f.write("the content")
        f.rewind
      end
    end

    it "successfully with a standard file" do
      mock_successful_user_send_file 'Equal bytes for everyone', file

      user.send_file('Equal bytes for everyone', file).should be_truthy
    end

    it "but fails when the user doesn't exist" do
      mock(HipChat::User).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { user.send_file "", file }.should raise_error(HipChat::UnknownUser)
    end

    it "but fails when we're not allowed to do so" do
      mock(HipChat::User).post(anything, anything) {
        OpenStruct.new(:code => 401)
      }

      lambda { user.send_file "", file }.should raise_error(HipChat::Unauthorized)
    end
  end
end
