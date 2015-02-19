require 'trello'
require 'launchy'
require 'yaml'

class Authorization
  DEVELOPER_PUBLIC_KEY = 'bf9a0ddb8c4cb08bf7c9223e12675705'

  def self.authorize
    Trello.configure do |config|
      config.developer_public_key = DEVELOPER_PUBLIC_KEY
      config.member_token         = member_token
    end
  end

  def self.member_token
    conf_file_path = File.expand_path('../../../conf/conf.yaml', __FILE__)
    if File.exist?(conf_file_path)
      config = YAML.load_file(conf_file_path)
      member_token = config['member_token']
    else
      url = member_token_url
      Launchy.open(url) do
        puts "Something went wrong, please open #{url} manually and paste token below."
      end
      puts 'paste your token below:'
      member_token = STDIN.gets.chomp
      config = {}
      config['member_token'] = member_token
      File.open(conf_file_path, 'w') { |f| f.write config.to_yaml }
    end
    member_token
  end

  def self.member_token_url
    'https://trello.com/1/authorize?' \
      "key=#{DEVELOPER_PUBLIC_KEY}&" \
      'expiration=30days&' \
      'response_type=token&' \
      'scope=read,write'
  end
end
