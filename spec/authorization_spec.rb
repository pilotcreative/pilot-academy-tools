require 'trello_automation'
describe TrelloAutomation::AutomationManager do
  include Helpers

  TEST_FILE = '/tmp/trello_spec'
  MEMBER_TOKEN = 'member_token'
  Authorization = TrelloAutomation::Authorization

  describe 'Authorization' do
    before do
      stub_const('Constants::DEVELOPER_PUBLIC_KEY', 'dpk')
      stub_const('Constants::APP_NAME', 'Test App Name')
      Authorization.stub(:token_file_path) { TEST_FILE }
    end

    context 'when there is token file in system' do
      before do
        Trello.configuration.member_token = nil
        Trello.configuration.developer_public_key = nil
        File.open(TEST_FILE, 'w') { |f| f.write "member_token: #{MEMBER_TOKEN}" }
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
        allow(Authorization).to receive(:read_token_from_stdin).and_return(MEMBER_TOKEN)
        File.delete(TEST_FILE) if File.exist?(TEST_FILE)
        expect(File.exist?(TEST_FILE)).to be_falsey
      end

      it 'opens browser to deliver the key' do
        expect(Authorization).to receive(:open_url_in_browser)
        Authorization.authorize
      end

      describe 'and stores the key from STDIN to file' do
        before do
          Authorization.stub(:open_url_in_browser)
        end

        it 'prompts user for the key' do
          expect(Authorization).to receive(:read_token_from_stdin)
          Authorization.authorize
        end

        it 'creates token file in system' do
          expect(File.exist?(TEST_FILE)).to be_falsey
          Authorization.authorize
          expect(File.exist?(TEST_FILE)).to be_truthy
        end

        it 'saves the key to the token file in system' do
          expect(File.exist?(TEST_FILE)).to be_falsey
          Authorization.authorize
          expect(File.open(TEST_FILE, 'r') { |f| f.read }).to include(MEMBER_TOKEN)
        end
      end

      describe 'Trello App URL' do
        before do
          url = Authorization.member_token_url
          $stdout = StringIO.new
          Authorization.open_url_in_browser(url, dry_run: true)
        end

        after do
          $stdout = STDOUT
        end

        it 'is streamed to $stdout by Launchy when dry_run: true' do
          expect(browsers.any? { |b| $stdout.string =~ /#{b}/ }).to be_truthy
          expect($stdout.string).to include('https://')
        end

        it 'includes correct DEVELOPER_PUBLIC_KEY' do
          expect($stdout.string).to include("key=#{Constants::DEVELOPER_PUBLIC_KEY}")
        end

        it 'includes corerct APP_NAME' do
          expect($stdout.string).to include("name=#{Constants::APP_NAME}")
        end

        it "queries 'response_type=token'" do
          expect($stdout.string).to include('response_type=token')
        end

        it "queries 'scope=read,write'" do
          expect($stdout.string).to include('scope=read,write')
        end
      end
    end
  end
end
