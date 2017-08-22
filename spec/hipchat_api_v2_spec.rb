require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require'tempfile'

describe "HipChat (API V2)" do

  subject { HipChat::Client.new("blah", :api_version => @api_version) }

  let(:room) { subject["Hipchat"] }
  let(:user) { subject.user "12345678" }

  describe "#scopes" do
    include_context "HipChatV2"
    let(:token_room) { nil }
    before { mock_successful_scopes room: token_room }

    context 'with a global API token' do
      context 'room parameter given' do
        it 'returns an array of global scopes' do
          expect(subject.scopes(room: room))
            .to match_array(['view_room', 'send_notification'])
        end
      end

      context 'no room parameter given' do
        it 'returns an array of global scopes' do
          expect(subject.scopes)
            .to match_array(['view_room', 'send_notification'])
        end
      end
    end

    context 'with a room API token' do
      let(:token_room) { room }

      context 'room parameter given' do
        context 'room parameter matches API token room' do
          it 'returns an array of global scopes' do
            expect(subject.scopes(room: room))
              .to match_array(['view_room', 'send_notification'])
          end
        end

        context 'room parameter does not match API token room' do
          let(:token_room) { double(room_id: 'Not-Hipchat') }
          it 'returns nil' do
            expect(subject.scopes(room: room)).to eq nil
          end
        end
      end

      context 'no room parameter given' do
        it 'returns nil' do
          expect(subject.scopes).to eq nil
        end
      end
    end

    it "fails if we get an unknown response code" do
      allow(subject.class)
        .to receive(:get).with(anything, anything)
        .and_return(OpenStruct.new(:code => 403))

      expect { subject.scopes }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe "#history" do
    include_context "HipChatV2"
    it "is successful without custom options" do
      mock_successful_history()

      expect(room.history()).to be_truthy
    end

    it "is successful with custom options" do
      mock_successful_history(:timezone => 'America/Los_Angeles', :date => '2010-11-19', :'max-results' => 10, :'start-index' => 10, :'end-date' => '2010-11-19')
      expect(room.history(:timezone => 'America/Los_Angeles', :date => '2010-11-19', :'max-results' => 10, :'start-index' => 10, :'end-date' => '2010-11-19')).to be_truthy
    end

    it "is successful from fetched room" do
      mock_successful_rooms
      mock_successful_history

      expect(subject.rooms).to be_truthy
      expect(subject.rooms.first.history).to be_truthy
    end

    it "fails when the room doesn't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { room.history }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.history }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.history }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe "#members" do
    include_context "HipChatV2"
    it "returns members" do
      mock_successful_members

      expect(room.members.first).to be_a HipChat::User
    end

    it "accepts pagination params" do
      mock_successful_second_thousand_members
      expect(room.members('max-results' => 1000, 'start-index' => 1000).first).
        to be_a HipChat::User
    end

    it "fails when the room doen't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))
      expect { room.members }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.members }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.members }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe "#participants" do
    include_context "HipChatV2"
    it "returns participants" do
      mock_successful_participants

      expect(room.participants.first).to be_a HipChat::User
    end

    it "accepts pagination params" do
      mock_successful_second_thousand_participants
      expect(room.participants('max-results' => 1000, 'start-index' => 1000).first).
        to be_a HipChat::User
    end

    it "fails when the room doen't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))
      expect { room.participants }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.participants }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.participants }.to raise_error(HipChat::Unauthorized)
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

    it "fails when the room doesn't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { room.statistics }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.statistics }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.statistics }.to raise_error(HipChat::Unauthorized)
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
      allow(room.class).to receive(:put).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { room.topic "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "fails when we're not allowed to do so" do
        allow(room.class).to receive(:put).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.topic "" }.to raise_error(HipChat::Unauthorized)
    end

    it "fails if we get an unknown response code" do
        allow(room.class).to receive(:put).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.topic "" }.to raise_error(HipChat::Unauthorized)
    end
  end



  describe "#send_message" do
    include_context "HipChatV2"
    it "successfully without custom options" do
      mock_successful_send_message 'Hello world'

      expect(room.send_message("Hello world")).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { room.send_message "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.send_message "" }.to raise_error(HipChat::Unauthorized)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.send_message "" }.to raise_error(HipChat::Unauthorized)
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

    it "successfully creates a card in the room" do
      card = {
        :style => 'application',
        :title => 'My Awesome Card',
        :id => 12345
      }
      mock_successful_send_card 'Dude', 'Hello world', card

      expect(room.send("Dude", "Hello world", :card => card)).to be_truthy
    end

    it "successfully with text message_format" do
      mock_successful_send 'Dude', 'Hello world', :message_format => 'text'

      expect(room.send("Dude", "Hello world", :message_format => 'text')).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { room.send "", "" }.to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { room.send "", "" }.to raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      expect { room.send "a very long username here", "a message" }.to raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect { room.send "", "" }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#reply' do
    include_context 'HipChatV2'
    let(:parent_id) { '100000' }
    let(:message)   { 'Hello world' }

    it 'successfully' do
      mock_successful_reply parent_id, message

      expect(room.reply(parent_id, message))
    end

    it "but fails when the parent_id doesn't exist" do
      allow(room.class).to receive(:post).and_return(OpenStruct.new(:code => 404))

      expect { room.reply parent_id, message }.to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).and_return(OpenStruct.new(:code => 401))

      expect { room.reply parent_id, message }.to raise_error(HipChat::Unauthorized)
    end

    it 'but fails if we get an unknown response code' do
      allow(room.class).to receive(:post).and_return(OpenStruct.new(:code => 403))

      expect { room.reply parent_id, message }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#share_link' do
    let(:link) { "http://i.imgur.com/cZ6GDFY.jpg" }
    include_context "HipChatV2"
    it "successfully" do
      mock_successful_link_share 'Dude', 'Sloth love Chunk!', link

      expect(room.share_link("Dude", "Sloth love Chunk!", link)).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.share_link "", "", link }).to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.share_link "", "", link }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      expect(lambda { room.share_link "a very long username here", "a message", link }).to raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.share_link "", "", link }).to raise_error(HipChat::Unauthorized)
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

      expect(room.send_file("Dude", "Hello world", file)).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.send_file "", "", file }).to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.send_file "", "", file }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if the username is more than 15 chars" do
      expect(lambda { room.send_file "a very long username here", "a message", file }).to raise_error(HipChat::UsernameTooLong)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.send_file "", "", file }).to raise_error(HipChat::Unauthorized)
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

  describe "#create_user" do
    include_context "HipChatV2"

    it "successfully with user name" do
      mock_successful_user_creation("A User", "email@example.com")

      expect(subject.create_user("A User", "email@example.com")).to be_truthy
    end

    it "successfully with custom parameters" do
      mock_successful_user_creation("A User", "email@example.com", {:title => "Super user", :password => "password", :is_group_admin => true})

      expect(subject.create_user("A User", "email@example.com", {:title => "Super user", :password => "password", :is_group_admin =>true})).to be_truthy
    end

    it "but fail is name is longer then 50 char" do
      expect { subject.create_user("A User that is too long that I should fail right now", "email@example.com") }.
        to raise_error(HipChat::UsernameTooLong)
    end
  end

  describe "#user_update" do
    include_context "HipChatV2"

    let(:user_update) {
      {
        :name => "Foo Bar",
        :presence => { status: "Away", show: "away" },
        :mention_name => "foo",
        :timezone => "GMT",
        :email => "foo@bar.org",
        :title => "mister",
        :is_group_admin => 0,
        :roles => []
      }
    }

    it "successfull" do
      mock_successful_user_update(user_update)

      user_update.delete(:presence)
                 .each { |key, value| user_update[key] = value }
      expect(user.update(user_update))
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

  describe "#delete_room" do
    include_context "HipChatV2"

    it "successfully" do
      mock_successful_delete_room("Hipchat",)
      expect(room.delete_room).to be_truthy
    end

    it "missing room" do
      mock_delete_missing_room("Hipchat")
      expect do
        room.delete_room
      end.to raise_exception(HipChat::UnknownRoom)
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

  describe "#add_member" do
    include_context "HipChatV2"

    it "successfully with user_id" do
      mock_successful_add_member()

      expect(room.add_member("1234")).to be_truthy
    end

    it "successfully with custom parameters" do
      mock_successful_add_member({:user_id => "321", :room_roles => ["room_admin","room_member"]})

      expect(room.add_member("321", ["room_admin","room_member"])).to be_truthy
    end
  end

  describe "#send user message" do
    include_context "HipChatV2"
    it "successfully with a standard message" do
      mock_successful_user_send 'Equal bytes for everyone'

      expect(user.send('Equal bytes for everyone')).to be_truthy
    end

    it "but fails when the user doesn't exist" do
      allow(user.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect { user.send "" }.to raise_error(HipChat::UnknownUser)
    end

    it "but fails when we're not allowed to do so" do
      allow(user.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect { user.send "" }.to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#get_user_history' do
    include_context 'HipChatV2'

    it 'successfully returns history' do
      mock_successful_user_history
      expect(user.history).to be_truthy
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

      expect(user.send_file('Equal bytes for everyone', file)).to be_truthy
    end

    it "but fails when the user doesn't exist" do
      allow(user.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { user.send_file "", file }).to raise_error(HipChat::UnknownUser)
    end

    it "but fails when we're not allowed to do so" do
      allow(user.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { user.send_file "", file }).to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#create_webhook' do
    include_context "HipChatV2"

    it "successfully with a valid room, url and event" do
      mock_successful_create_webhook('Hipchat', 'https://example.org/hooks/awesome', 'room_enter')

      expect(room.create_webhook('https://example.org/hooks/awesome', 'room_enter')).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.create_webhook('https://example.org/hooks/awesome', 'room_enter') }).to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.create_webhook('https://example.org/hooks/awesome', 'room_enter') }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if the url is invalid" do
      expect(lambda { room.create_webhook('foo://bar.baz/', 'room_enter') }).to raise_error(HipChat::InvalidUrl)
    end

    it "but fails if the event is invalid" do
      expect(lambda { room.create_webhook('https://example.org/hooks/awesome', 'room_vandalize') }).to raise_error(HipChat::InvalidEvent)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:post).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.create_webhook('https://example.org/hooks/awesome', 'room_enter') }).to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#delete_webhook' do
    include_context "HipChatV2"

    it "successfully deletes a webhook with a valid webhook id" do
      mock_successful_delete_webhook('Hipchat', 'my_awesome_webhook')

      expect(room.delete_webhook('my_awesome_webhook')).to be_truthy
    end

    it "but fails when the webhook doesn't exist" do
      allow(room.class).to receive(:delete).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.delete_webhook('my_awesome_webhook') }).to raise_error(HipChat::UnknownWebhook)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:delete).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.delete_webhook('my_awesome_webhook') }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:delete).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.delete_webhook('my_awesome_webhook') }).to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#get_all_webhooks' do
    include_context "HipChatV2"

    it "successfully lists webhooks with a valid room id" do
      mock_successful_get_all_webhooks('Hipchat')

      expect(room.get_all_webhooks).to be_truthy
    end

    it "but fails when the room doesn't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.get_all_webhooks }).to raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.get_all_webhooks }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.get_all_webhooks }).to raise_error(HipChat::Unauthorized)
    end
  end

  describe '#get_webhook' do
    include_context "HipChatV2"

    it "successfully gets webhook info with valid room and webhook ids" do
      mock_successful_get_webhook('Hipchat', '5678')

      expect(room.get_webhook('5678')).to be_truthy
    end

    it "but fails when the webhook doesn't exist" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 404))

      expect(lambda { room.get_webhook('5678') }).to raise_error(HipChat::UnknownWebhook)
    end

    it "but fails when we're not allowed to do so" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 401))

      expect(lambda { room.get_webhook('5678') }).to raise_error(HipChat::Unauthorized)
    end

    it "but fails if we get an unknown response code" do
      allow(room.class).to receive(:get).with(anything, anything).and_return(OpenStruct.new(:code => 403))

      expect(lambda { room.get_webhook('5678') }).to raise_error(HipChat::Unauthorized)
    end
  end
end
