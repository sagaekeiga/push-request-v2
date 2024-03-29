# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'simplecov'

SimpleCov.add_filter do |source_file|
  filename = source_file.filename
  filename =~ /spec/
end

SimpleCov.start 'rails' do
  add_filter '/spec/'
end

SimpleCov.coverage_dir('coverage')

ActiveRecord::Migration.maintain_test_schema!
Rails.logger = Logger.new(STDOUT)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Devise::Test::ControllerHelpers, type: :controller
end
