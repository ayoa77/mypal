namespace :conversations do
  desc "Notify unread"
  task notify_unread: :environment do
    default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
      if db[0].starts_with?("blnkk")
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))
        ConversationUser.notify_about_unread_messages
      end
    end  
  end
end