namespace :users do
  desc "Add gravatar to all users without an avatar"
  task add_avatar: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Adding gravatars to users in database #{db[0]} ..."  
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}")) 
        User.where(avatar_uid: nil).each do |user|
          user.avatar_url = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}?s=512&d=mm"
          user.save
          puts "Updated avatar for #{user.name}"
        end
      end
    end
  end

  desc "Send fresh new posts"
  task :send_fresh_new_posts => :environment do |t, args|
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        puts "Sending fresh new posts to users in database #{db[0]} ..."
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        User.where(enabled: true).each do |u|
          u.send_fresh_new_posts
        end
      end
    end  
  end

end

