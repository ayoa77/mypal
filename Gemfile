if RUBY_VERSION =~ /2.1.5/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'

# gem install libv8 -v '3.16.14.7'  -- --with-system-v8
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.8'
if RUBY_VERSION =~ /2.1.5/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.3.20'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '~>0.12.3', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use unicorn as the app server
# gem 'unicorn'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'byebug', group: [:development, :test]
# Use debugger
# gem 'debugger', group: [:development, :test]
gem 'will_paginate', '~> 3.0.6'
gem 'haml'
gem 'paypal-sdk-rest'
gem 'rest-client'
gem 'jwt'

gem 'websocket-rails'

group :development do
  gem 'annotate'
  gem 'awesome_print'
  gem 'capistrano', '~> 3.4.0'
  gem 'colorize', '0.7.4'
  gem 'capistrano-slackify', '~> 2.2.0'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end

gem 'acts-as-taggable-on', '~> 3.4'

# angular gems
gem 'bower-rails'
gem 'angular-rails-templates'

# Use active_model_serializers for serializing models to json
gem 'active_model_serializers'

# gems for bootstrap
# gem 'bootstrap-sass'
# gem 'autoprefixer-rails'

# state machine for meetings
gem 'workflow'

# to execute scheduled tasks
gem 'whenever'

# get notified of server errors
gem 'exception_notification'

# gem for markdown to html conversion
gem 'redcarpet'

gem 'slack-notifier'

# For storing images in models
gem 'dragonfly'
# gem 'rack-cache', :require => 'rack/cache'
gem 'angularjs-file-upload-rails', '~> 1.1.6'

# fluentd related gems
# gem 'act-fluent-logger-rails'
# gem 'lograge'


# elasticsearch
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
# gem 'kibana-rack', '~> 0.1.0'

#i18n
gem "i18n-js", ">= 3.0.0.rc8"

# jobs
gem 'resque'
gem 'resque-web', require: 'resque_web'
gem "capistrano-resque", "~> 0.2.1", require: false

gem 'redis', '3.2.0', :require => ["redis", "redis/connection/hiredis"]

gem 'sitemap_generator'

gem 'browser'

gem 'stringex'
