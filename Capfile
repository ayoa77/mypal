# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano-passenger'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   gem 'annotate'
  # gem 'awesome_print'
  # gem 'capistrano', '~> 3.4.0'
  # gem 'colorize', '0.7.4'
  # gem 'capistrano-slackify', '~> 2.2.0'
  # gem 'capistrano-rails'
  # gem 'capistrano-passenger'
  # gem 'capistrano-bundler'
  # gem 'capistrano-rvm'
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require "whenever/capistrano"
require "capistrano-resque"

require 'capistrano/sitemap_generator'


# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

Rake::Task[:production].invoke
