require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

ENV.update YAML.load(File.read('config/application.yml'))[Rails.env] rescue {}

module Blnkk
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    
    config.active_record.raise_in_transactional_callbacks = true

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = [:en, "zh-TW", "zh-CN"]
    config.i18n.default_locale = :en

    # config.assets.paths << Rails.root.join("lib","assets","bower_components","bootstrap-sass-official", "assets", "stylesheets")
    # config.assets.paths << Rails.root.join("lib","assets","bower_components","bootstrap-sass-official", "assets","fonts")
    config.assets.paths << Rails.root.join("lib","assets","bower_components","ng-tags-input")

    # fluentd logging
    # Fluent::Logger::FluentLogger.open(nil, :host=>'127.0.0.1', :port=>24224)
      initializer 'setup_asset_pipeline', :group => :all  do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg',         # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
          '.js', 
        ]
      end)
    end
  end
end
