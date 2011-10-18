require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do
  subject { HipChat::Client.new("blah") }

  let(:room) { subject["Hipchat"] }
  
  # Helper for mocking room message post requests
  def mock_successful_send(from, message, options={})
    options = {:color => 'yellow', :notify => 0}.merge(options)
    mock(HipChat::Room).post("/message",
                             :query => {:auth_token => "blah"},
                             :body  => {:room_id => "Hipchat",
                                        :from    => "Dude",
                                        :message => "Hello world",
                                        :color   => options[:color],
                                        :notify  => options[:notify]}) {
      OpenStruct.new(:code => 200)
    }    
  end

  describe "sends a message to a room" do
    it "successfully without custom options" do
      mock_successful_send 'Dude', 'Hello world'
      
      room.send("Dude", "Hello world").should be_true
    end
    
    it "successfully with notifications on as boolean" do
      mock_successful_send 'Dude', 'Hello world', :notify => 1

      room.send("Dude", "Hello world", true).should be_true
    end
    
    it "successfully with notifications off as boolean" do
      mock_successful_send 'Dude', 'Hello world', :notify => 0

      room.send("Dude", "Hello world", false).should be_true
    end
    
    it "successfully with notifications on as option" do
      mock_successful_send 'Dude', 'Hello world', :notify => 1

      room.send("Dude", "Hello world", :notify => true).should be_true
    end
    
    it "successfully with custom color" do
      mock_successful_send 'Dude', 'Hello world', :color => 'red'

      room.send("Dude", "Hello world", :color => 'red').should be_true
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
