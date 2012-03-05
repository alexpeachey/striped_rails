source 'https://rubygems.org'

gem 'rails', '3.2.2'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'jquery-rails'
gem 'haml', '3.1.4'
gem 'haml-rails', '0.3.4'
gem 'unicorn', '4.2.0'
gem 'friendly_id', "4.0.0"
gem 'draper', '0.10.0'
gem 'stripe'
gem 'bootstrap-sass'
gem 'simple_form', '2.0.1'
gem 'dalli', '1.1.5'
gem 'redis', '2.2.2'
# use git repo for resque to have latest sinatra fix.
gem 'resque', require: 'resque/server', git: 'https://github.com/defunkt/resque.git'
gem 'newrelic_rpm'

group :production, :staging do
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rspec-rails', '2.8.1'
  gem 'rb-fsevent', '0.9.0'
  gem 'growl', '1.0.3'
  gem 'guard-rspec', '0.6.0'
  gem 'guard-spork', '0.5.2'
  gem 'foreman'
  gem 'letter_opener'
  gem 'heroku'
end

group :test do
  gem 'rspec-rails', '2.8.1'
  gem 'factory_girl_rails', '1.6.0'
  gem 'database_cleaner', '0.7.1'
  gem 'capybara', '1.1.2'
  gem 'fakeweb', '1.3.0'
end
