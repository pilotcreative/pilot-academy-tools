require 'trello_automation'
describe TrelloAutomation::AutomationManager do
  include Helpers

  TEST_FILE = '/tmp/trello_spec'
  MEMBER_TOKEN = 'member_token'
  Authorization = TrelloAutomation::Authorization

  describe 'Authorization' do
    before do
      Trello.configuration.member_token = nil
      Trello.configuration.developer_public_key = nil
      stub_const('Constants::DEVELOPER_PUBLIC_KEY', 'dpk')
      stub_const('Constants::APP_NAME', 'Test App Name')
    end

    context 'when there is token file in system' do
      before do
        File.open(TEST_FILE, 'w') { |f| f.write "member_token: #{MEMBER_TOKEN}" }
        Authorization.stub(:token_file_path) { TEST_FILE }
      end

      after do
        expect(File.delete(TEST_FILE)).to eq(1)
      end

      it 'sets member token' do
        expect(Trello.configuration.member_token).to be_nil
        Authorization.authorize
        expect(Trello.configuration.member_token).not_to be_nil
      end

      it 'sets developer public key' do
        expect(Trello.configuration.developer_public_key).to be_nil
        Authorization.authorize
        expect(Trello.configuration.developer_public_key).not_to be_nil
      end

      it 'reads member token correctly' do
        Authorization.authorize
        expect(Trello.configuration.member_token).to eq(MEMBER_TOKEN)
      end

      it 'reads developer public key correctly' do
        Authorization.authorize
        expect(Trello.configuration.developer_public_key).to eq(Constants::DEVELOPER_PUBLIC_KEY)
      end
    end

    context 'when there is no token file in system' do
      before do
        @url = Authorization.member_token_url
        Authorization.stub(:token_file_path) { TEST_FILE }
        $stdout = StringIO.new
        Authorization.open_url_in_browser(@url, dry_run: true)
      end

      after do
        $stdout = STDOUT
      end

      it 'opens browser to deliver the key' do
        expect(browsers.any? { |b| $stdout.string =~ /#{b}/ }).to be_truthy
        expect($stdout.string).to include('https://')
      end

      xit 'prompts user for the key' do
      end

      xit 'creates token file in system' do
      end

      xit 'saves the key to the token file in system' do
      end

      describe 'Trello App URL' do
        it 'includes correct DEVELOPER_PUBLIC_KEY' do
          expect($stdout.string).to include("key=#{Constants::DEVELOPER_PUBLIC_KEY}")
        end

        it 'includes corerct APP_NAME' do
          expect($stdout.string).to include("name=#{Constants::APP_NAME}")
        end

        it 'queries response type = token' do
          expect($stdout.string).to include('response_type=token')
        end

        it 'queries scope = read and write' do
          expect($stdout.string).to include('scope=read,write')
        end
      end
    end
  end
end
