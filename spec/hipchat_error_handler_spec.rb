require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat::ErrorHandler do
  let(:body)     { { error: { code: code, message: 'any', type: 'any' } } }
  let(:request)  { HTTParty::Request.new(Net::HTTP::Get, 'http://foo.com/') }
  let(:response) { HTTParty::Response.new(request, response_object, lambda { body }) }
  let(:room_id)  { 'Hipchat' }
  before do
    allow(response_object).to receive_messages(body: body.to_json)
  end


  describe 'response_code_to_exception_for' do
    subject { HipChat::ErrorHandler.response_code_to_exception_for(:room, room_id, response) }

    context 'success codes' do
      shared_examples 'the error handler' do
        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end

      context 'Hipchat API responds with success' do
        describe 'code 200' do
          let(:response_object) { Net::HTTPOK.new('1.1', code, '') }
          let(:code)            { 200 }
          it_should_behave_like 'the error handler'
        end

        describe 'code 201' do
          let(:response_object) { Net::HTTPCreated.new('1.1', code, '') }
          let(:code)            { 201 }
          it_should_behave_like 'the error handler'
        end

        describe 'code 202' do
          let(:response_object) { Net::HTTPAccepted.new('1.1', code, '') }
          let(:code)            { 202 }
          it_should_behave_like 'the error handler'
        end

        describe 'code 204' do
          let(:response_object) { Net::HTTPNoContent.new('1.1', code, '') }
          let(:code)            { 204 }
          it_should_behave_like 'the error handler'
        end
      end
    end

    context 'failure codes' do
      shared_examples 'the error handler' do
        it "raises the correct client error" do
          expect { subject }
            .to raise_error(client_error) do |error|
              expect(error.message)
                .to match message
            end
        end
      end

      context 'Hipchat API responds with Not Found' do
        let(:response_object) { Net::HTTPNotFound.new('1.1', code, '') }
        let(:client_error)    { HipChat::UnknownRoom }
        let(:message)         { "Unknown room: `#{room_id}\':\nResponse: #{body.to_json}" }

        describe 'code 404' do
          let(:code) { 404 }
          it_should_behave_like 'the error handler'
        end
      end

      context 'Hipchat API responds with Unauthorized' do
        let(:response_object) { Net::HTTPUnauthorized.new('1.1', code, '') }
        let(:client_error)    { HipChat::Unauthorized }
        let(:message)         { "Access denied to room `#{room_id}\':\nResponse: #{body.to_json}" }

        describe 'code 401' do
          let(:code) { 401 }
          it_should_behave_like 'the error handler'
        end

        describe 'code 403' do
          let(:code) { 403 }
          it_should_behave_like 'the error handler'
        end
      end

      context 'Hipchat API responds with Bad Request' do
        let(:response_object) { Net::HTTPBadRequest.new('1.1', code, '') }
        let(:client_error)    { HipChat::BadRequest }
        let(:message)         { "The request was invalid. You may be missing a required argument or provided bad data. path:http://foo.com/ method:Net::HTTP::Get:\nResponse: #{body.to_json}" }

        describe 'code 400' do
          let(:code) { 400 }
          it_should_behave_like 'the error handler'
        end
      end

      context 'Hipchat API responds with MethodNotAllowed' do
        let(:response_object) { Net::HTTPMethodNotAllowed.new('1.1', code, '') }
        let(:client_error)    { HipChat::MethodNotAllowed }
        let(:message)         { "You requested an invalid method. path:http://foo.com/ method:Net::HTTP::Get:\nResponse: #{body.to_json}" }

        describe 'code 405' do
          let(:code) { 405 }
          it_should_behave_like 'the error handler'
        end
      end

      context 'Hipchat API responds with TooManyRequests' do
        let(:response_object) { Net::HTTPTooManyRequests.new('1.1', code, '') }
        let(:client_error)    { HipChat::TooManyRequests }
        let(:message)         { "You have exceeded the rate limit. `https://www.hipchat.com/docs/apiv2/rate_limiting`:\nResponse: #{body.to_json}" }

        describe 'code 429' do
          let(:code) { 429 }
          it_should_behave_like 'the error handler'
        end
      end

      context 'Hipchat API responds with an unknown response code' do
        let(:response_object) { Net::HTTPBadGateway.new('1.1', code, '') }
        let(:client_error)    { HipChat::UnknownResponseCode }
        let(:message)         { "Unexpected 502 for room `#{room_id}\'" }

        describe 'code 502' do
          let(:code) { 502 }
          it_should_behave_like 'the error handler'
        end
      end
    end
  end
end
