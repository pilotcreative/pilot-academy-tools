require 'trello'
require 'launchy'
require 'yaml'

class Authorization
  DEVELOPER_PUBLIC_KEY = 'bf9a0ddb8c4cb08bf7c9223e12675705'

  def self.authorize
    Trello.configure do |config|
      config.developer_public_key = DEVELOPER_PUBLIC_KEY
      config.member_token = member_token
    end
  end

  def self.member_token
    token_file_path = File.expand_path('~/.trello_token', __FILE__)
    if File.exist?(token_file_path)
      YAML.load_file(token_file_path)['member_token']
    else
      create_new_token_file(token_file_path)['member_token']
    end
  end

  def self.create_new_token_file(token_file_path)
    token_hash = {}
    url = member_token_url('never')
    Launchy.open(url) { |exception| exception_message(url, exception) }
    token_hash['member_token'] = read_token_from_stdin
    File.open(token_file_path, 'w') { |f| f.write token_hash.to_yaml }
    token_hash
  end

  def self.member_token_url(expiry = '') # [ never | 30days (default) ]
    'https://trello.com/1/authorize?' \
      "key=#{DEVELOPER_PUBLIC_KEY}&" \
      'response_type=token&' \
      "expiration=#{expiry}&" \
      'scope=read,write'
  end

  def self.exception_message(url, exception)
    puts "Launchy exception thrown:\n#{exception}\nPlease open #{url} manually and paste the token below:"
  end

  def self.read_token_from_stdin
    puts 'Please paste your token:'
    STDIN.gets.chomp
  end
end
