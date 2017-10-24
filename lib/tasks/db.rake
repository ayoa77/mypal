namespace :db do
  desc "Migrate all databases"
  task migrate: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Migrating database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        ActiveRecord::Migrator.migrate("db/migrate")
      end
    end
  end

  desc "Rollback all databases"
  task rollback: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Rollbacking database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        ActiveRecord::Migrator.rollback("db/migrate")
      end
    end
  end

  desc "Inject all settings"
  task inject_settings: :environment do
    # ActiveRecord::Base.establish_connection(...)
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Injecting settings in database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        Setting.find_by(key: "SITE_NAME") || Setting.create(key: "SITE_NAME", value: "Hey Lions Club")
        Setting.find_or_create_by(key: "SUBSITE")
        Setting.find_or_create_by(key: "SITE_URL")
        Setting.find_or_create_by(key: "COLOR")
        Setting.find_by(key: "LOCALE_PRIMARY") || Setting.create(key: "LOCALE_PRIMARY", value: "en")
        Setting.find_or_create_by(key: "LOCALE_SECONDARY")
        Setting.find_by(key: "STYLES_BACKGROUND_URL") || Setting.create(key: "STYLES_BACKGROUND_URL", value: "https://www.hs-neu-ulm.de/fileadmin/_processed_/csm_Gruppenbild_06_90a7e26f78.jpg")
        Setting.find_by(key: "STYLES_LOGO") || Setting.create(key: "STYLES_LOGO", value: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fb/Banc_de_Binary_Lion.svg/2000px-Banc_de_Binary_Lion.svg.png")
        Setting.find_by(key: "STYLES_TEXT_COLOR") || Setting.create(key: "STYLES_TEXT_COLOR", value: "white")
        Setting.find_by(key: "STYLES_TAGLINE_PRIMARY") || Setting.create(key: "STYLES_TAGLINE_PRIMARY", value: "We’re Making a World of Difference")
        Setting.find_by(key: "STYLES_TAGLINE_SECONDARY") || Setting.create(key: "STYLES_TAGLINE_SECONDARY", value: "Lions are changing the world one community at a time, by addressing needs at home and around the globe. We are 1.4 million men and women who believe that kindness matters. And when we work together, we can achieve bigger goals.")
        Setting.find_by(key: "STYLES_TAGLINE_EN_FONT") || Setting.create(key: "STYLES_TAGLINE_EN_FONT", value: "Helvetica")
        Setting.find_by(key: "STYLES_TAGLINE_ZH_FONT") || Setting.create(key: "STYLES_TAGLINE_ZH_FONT", value: "冬青黑体")
        Setting.find_by(key: "STYLES_TAGLINE_PRIMARY_SIZE") || Setting.create(key: "STYLES_TAGLINE_PRIMARY_SIZE", value: "60")
        Setting.find_by(key: "STYLES_TAGLINE_SECONDARY_SIZE") || Setting.create(key: "STYLES_TAGLINE_SECONDARY_SIZE", value: "22")
    
        # Setting.find_or_create_by(key: "DESCRIPTION_PRIMARY")
        # Setting.find_or_create_by(key: "DESCRIPTION_SECONDARY")
        Setting.find_by(key: "CHINA") || Setting.create(key: "CHINA", value: "0")
        Setting.find_by(key: "PRIVATE") || Setting.create(key: "PRIVATE", value: "0")
        Setting.find_or_create_by(key: "ADMIN_EMAIL")

        # if !ActsAsTaggableOn::Tag.find_by(id: 1)
        #   ActsAsTaggableOn::Tag.create(id: 1, name: "welcome", display_name: "Welcome")
        # end
      end
    end
  end

  desc "Import all models into elasticsearch"
  task elasticsearch_import: :environment do
    # ActiveRecord::Base.establish_connection(...)
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Importing database #{db[0]} into elasticsearch ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        begin
          # Request.import force: true
          User.all.each do |u|
            Resque.enqueue(UserIndexJob, :index, u.id, ActiveRecord::Base.connection.current_database)
          end
        rescue => err
          puts "Bummer, unable to import models into elasticsearch: #{err} :'("
          ExceptionNotifier.notify_exception(err)
        end

      end
    end
  end


  desc "Recalculate everyting"
  task recalculate: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Recalculating database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        begin
          Request.all.each do |r|
            r.recalculate
          end
          User.all.each do |u|
            u.recalculate
          end
        rescue => err
          puts "Bummer, unable to recalculate: #{err} :'("
          ExceptionNotifier.notify_exception(err)
        end
      end
    end  
  end

  desc "Populate daily stats"
  task populate_daily_stats: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Populating daily stats of database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        DailyStat.populate
      end
    end  
  end

  desc "Clear logs"
  task clear_logs: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Clearing logs of database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        ActiveRecord::Base.connection.execute("TRUNCATE `logs`")
      end
    end  
  end

end