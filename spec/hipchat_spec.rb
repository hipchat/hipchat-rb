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
                                          :notify  => 0}) {
        OpenStruct.new(:code => 200)
      }

      room.send "Dude", "Hello world"
    end

    it "but fails when the room doesn't exist" do
      mock(HipChat::Room).post(anything, anything) {
        OpenStruct.new(:code => 404)
      }

      lambda { room.send "", "" }.should raise_error(HipChat::UnknownRoom)
    end
  end
end
