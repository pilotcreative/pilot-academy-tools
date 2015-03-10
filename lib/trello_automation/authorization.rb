module TrelloAutomation
  class Authorization
    def self.authorize
      Configuration.configuration
      Trello.configure do |config|
        config.developer_public_key = Constants::DEVELOPER_PUBLIC_KEY
        config.member_token = member_token
      end
    end

    def self.member_token
      if File.exist?(token_file_path)
        YAML.load_file(token_file_path)['member_token']
      else
        create_new_token_file(token_file_path)['member_token']
      end
    end

    def self.create_new_token_file(token_file_path)
      token_hash = {}
      open_url_in_browser(member_token_url)
      token_hash['member_token'] = read_token_from_stdin
      File.open(token_file_path, 'w') { |f| f.write token_hash.to_yaml }
      token_hash
    end

    def self.member_token_url(expiry = 'never') # [ never | 30days (default) ]
      'https://trello.com/1/authorize?' \
        "key=#{Constants::DEVELOPER_PUBLIC_KEY}&" \
        'response_type=token&' \
        "name=#{Constants::APP_NAME}&" \
        "expiration=#{expiry}&" \
        'scope=read,write'
    end

    def self.exception_message(url, exception)
      Configuration.logger.error { "Launchy exception thrown: #{exception}" }
      Configuration.logger.error { "Please open #{url} and paste the token below:" }
    end

    def self.read_token_from_stdin
      Configuration.logger.info { "Please paste your token: "  }
      STDIN.gets.chomp
    end

    private

    def self.token_file_path
      File.expand_path('~/.trello_token')
    end

    def self.open_url_in_browser(url, options = {})
      Launchy.open(url, options) { |exception| exception_message(url, exception) }
    end
  end
end
