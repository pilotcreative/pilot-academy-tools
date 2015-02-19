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
    config_file_path = File.expand_path('~/.trello_token', __FILE__)
    if File.exist?(config_file_path)
      config = YAML.load_file(config_file_path)
      config['member_token']
    else
      config = {}
      url = member_token_url('never')
      Launchy.open(url) { |exception| exception_message(url, exception) }
      puts 'Please paste your token:'
      config['member_token'] = STDIN.gets.chomp
      File.open(config_file_path, 'w') { |f| f.write config.to_yaml }
      config['member_token']
    end
  end

  def self.member_token_url(expiry = '') # accepts: never / ndays
    'https://trello.com/1/authorize?' \
      "key=#{DEVELOPER_PUBLIC_KEY}&" \
      'response_type=token&' \
      "expiration=#{expiry}&" \
      'scope=read,write'
  end

  def self.exception_message(url, exception)
    puts "Launchy exception thrown:\n#{exception}\nPlease open #{url} manually and paste the token below:"
  end
end
