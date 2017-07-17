namespace :websocket do
  desc "Restart the websocket server"
  task restart: :environment do
    begin
      puts "Stopping websocket rails server ..."
      Rake::Task["websocket_rails:stop_server"].invoke
    rescue => err
      puts "Bummer, unable to stop: #{err} :'("
      ExceptionNotifier.notify_exception(err)
    end
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Putting everbody on offline in database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        User.where(online:true).update_all(online: false, last_seen_at: Time.now)
      end
    end
    begin
      puts "Starting websocket rails server ..."
      Rake::Task["websocket_rails:start_server"].invoke
    rescue => err
      puts "Bummer, unable to start: #{err} :'("
      ExceptionNotifier.notify_exception(err)
    end
  end

end
