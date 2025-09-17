source "https://rubygems.org"


ruby "3.0.6"
gem "rails", "~> 7.1.0"
gem "mysql2", "~> 0.5"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bigdecimal", "~> 3.1"
gem 'bcrypt', '~> 3.1.7'
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]

gem 'will_paginate', '~> 3.3'
gem 'jquery-rails', '~> 4.6'
gem 'sassc-rails', '~> 2.1'
gem 'popper_js',     '~> 1.16.0'
gem 'bootstrap',     '~> 4.6', '>= 4.6.2'
gem 'coffee-rails', '~> 5.0'

group :development do
  # dev のファイル監視に必要
  # gem 'listen', '~> 3.8'
end

# gem "bootsnap", require: false


group :development, :test do
  gem 'faker', '~> 3.0'
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ]
end


group :development do
  gem "web-console"
end


group :test do
  gem "capybara"
  gem "selenium-webdriver"
end