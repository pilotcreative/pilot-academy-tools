require 'trello_automation'
require 'bundler/setup'
Bundler.setup

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

module Helpers
  # def boards_details
  #   [{
  #     'id'             => 'abcdef123456789123456789',
  #     'name'           => 'Test',
  #     'desc'           => 'This is a test board',
  #     'closed'         => false,
  #     'idOrganization' => 'abcdef123456789123456789',
  #     'url'            => 'https://trello.com/board/test/abcdef123456789123456789'
  #   }]
  # end

  def browsers
    browsers = %w( firefox iceweasel seamonkey opera mozilla netscape galeon chrome chromium )
    browsers << File.basename(ENV['BROWSER']) if ENV['BROWSER']
  end
end

include Helpers
