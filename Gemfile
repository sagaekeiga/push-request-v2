source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'pg', '~> 0.18'
group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
end

gem 'json'
gem 'jwt'
gem 'oj'
gem 'oj_mimic_json'
gem 'bcrypt-ruby'
gem 'carrierwave'
gem 'file_validators'
gem 'rmagick'
gem 'fog'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'
gem 'rails-i18n'
gem 'awesome_print'
gem 'config'
gem 'aws-sdk'
gem 'paranoia'
gem 'annotate'
gem 'enum_help'
gem 'inky-rb', require: 'inky'
gem 'premailer-rails'
gem 'draper'
gem 'activemodel-serializers-xml'
gem 'guard'
gem 'meta-tags'
gem 'ransack'
gem 'pundit'
gem 'cocoon'
gem 'haml-rails'
gem 'font-awesome-sass'
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'hiredis', require: ["redis", "redis/connection/hiredis"]
gem 'redis'
gem 'redis-namespace'
gem 'redis-objects'
gem 'connection_pool'
gem 'httparty'
gem 'sidekiq'
gem 'audited'
gem 'acts-as-taggable-on'
gem 'factory_bot'
gem 'bootstrap-generators'
gem 'faker'
gem 'faker-japanese'
gem 'breadcrumbs_on_rails'
gem 'i18n-tasks'
gem 'google-analytics-rails'
gem 'dotenv-rails'
gem 'honoka-rails'
group :development, :test do
  gem 'timecop'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'erb2haml'
  gem 'database_cleaner'
  gem 'rspec-request_describer'
  gem 'database_rewinder'
  gem 'json_spec'
  gem 'guard-rspec'
  gem 'rubocop', require: false
  gem 'letter_opener_web'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development do
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'hirb'
  gem 'hirb-unicode'
end

gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2', '0.5.0'
gem 'foreman'
source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-fileinput'
  gem 'rails-assets-eonasdan-bootstrap-datetimepicker'
end
