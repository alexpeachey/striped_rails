require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  RSpec.configure do |config|
    config.mock_with :rspec
    # config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      # For test we will use Redis Database 2
      REDIS.select 2
      uri = URI.parse(ENV["REDISTOGO_URL"])
      Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password, db: 2)
    end
    config.before(:each) do
      DatabaseCleaner.start
    end
    config.after(:each) do
      DatabaseCleaner.clean
      Resque.queues.each do |q|
        Resque.remove_queue(q)
      end
      REDIS.flushdb
    end
    #Draper Fix
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.before(:all, :draper_with_helpers) do
      c = ApplicationController.new
      c.request = ActionDispatch::TestRequest.new
      c.set_current_view_context
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end
