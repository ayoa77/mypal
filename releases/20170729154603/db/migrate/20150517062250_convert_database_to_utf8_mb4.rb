class ConvertDatabaseToUtf8Mb4 < ActiveRecord::Migration
  def change

    execute "DELETE FROM `contacts` WHERE length(`email`) > 191"
    execute "ALTER TABLE `contacts` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `contacts` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    
    execute "ALTER TABLE `email_settings` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    
    execute "ALTER TABLE `invitations` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    

    execute "ALTER TABLE `locations` CHANGE `city` `city` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `locations` CHANGE `region` `region` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `locations` CHANGE `country` `country` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `locations` CHANGE `region_code` `region_code` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `locations` CHANGE `country_code` `country_code` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    
    execute "ALTER TABLE `pages` CHANGE `key` `key` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `pages` CHANGE `header` `header` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE `payments` CHANGE `payment_id` `payment_id` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `payments` CHANGE `redirect_url` `redirect_url` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `payments` CHANGE `token` `token` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `payments` CHANGE `capture_id` `capture_id` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
            
    execute "ALTER TABLE `ratings` CHANGE `rateable_type` `rateable_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    
    execute "ALTER TABLE `requests` CHANGE `workflow_state` `workflow_state` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE `taggings` CHANGE `taggable_type` `taggable_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `taggings` CHANGE `tagger_type` `tagger_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE `tags` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `tags` CHANGE `icon` `icon` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE `schema_migrations` CHANGE `version` `version` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

    execute "ALTER TABLE `users` CHANGE `email` `email` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `name` `name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `avatar_uid` `avatar_uid` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `language` `language` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `paypal` `paypal` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `website` `website` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `linkedin_url` `linkedin_url` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `linkedin_name` `linkedin_name` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE `users` CHANGE `ip` `ip` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
                                              
    execute "ALTER TABLE `viewings` CHANGE `viewable_type` `viewable_type` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    
    # for each table that will store unicode execute:
    ['comments','contacts','conversations','conversation_users','daily_stats','email_settings','invitations','locations','messages','pages','payments','ratings','requests','request_users','schema_migrations','taggings','tags','users','viewings'].each do |t|
      execute "ALTER TABLE `#{t}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    end
  end
end
