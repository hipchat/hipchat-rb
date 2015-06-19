require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do

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

  describe 'options' do

    context "api_version" do

      it "defaults to a v1 client" do
        client = HipChat::Client.new("blah")
        expect(client[:example].api_version).to eql('v1')
      end

      it "when given 'v1' it registers a v1 client" do
        client = HipChat::Client.new("blah", :api_version => 'v1')
        expect(client[:example].api_version).to eql('v1')
      end

      it "when given 'v2' it registers a v2 client" do
        client = HipChat::Client.new("blah", :api_version => 'v2')
        expect(client[:example].api_version).to eql('v2')
      end
    end

    context "server_url" do

      it "defaults to 'https://api.hipchat.com'" do
        client = HipChat::Client.new("derr")
        expect(client[:example].server_url).to eql('https://api.hipchat.com')
      end

      it "can be overridden to 'http://hipchat.example.com'" do
        client = HipChat::Client.new("derr", :server_url => 'http://hipchat.example.com')
        expect(client[:example].server_url).to eql('http://hipchat.example.com')
      end
    end
  end
end

