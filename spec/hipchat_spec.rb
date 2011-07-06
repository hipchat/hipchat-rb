require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do
  subject { HipChat::Client.new("blah") }

  let(:room) { subject["Hipchat"] }

  describe "sends a message to a room" do
    it "successfully" do
      mock(HipChat::Room).post("/message",
                               :query => {:auth_token => "blah"},
                               :body  => {:room_id => "Hipchat",
                                          :from    => "Dude",
                                          :message => "Hello world",
                                          :notify  => 0})

      room.send "Dude", "Hello world"
    end
  end
end
