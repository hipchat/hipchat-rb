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
end
