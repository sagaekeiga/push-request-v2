require 'devise'
require 'rspec/request_describer'
require 'json_spec'
require 'factory_bot_rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.before :each do
    DatabaseRewinder.clean_all
    Rails.application.load_seed
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.include Warden::Test::Helpers
  config.include RSpec::RequestDescriber, type: :request
  config.include JsonSpec::Helpers, type: :request
  config.include FactoryBot::Syntax::Methods
end

shared_examples :common_api_response_format do
  it 'APIはバージョン情報とレスポンス内容を返す' do
    expect_response_format
  end
end
