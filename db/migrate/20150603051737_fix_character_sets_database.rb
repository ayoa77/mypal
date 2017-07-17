class FixCharacterSetsDatabase < ActiveRecord::Migration
  def change
    execute "ALTER DATABASE `#{ActiveRecord::Base.connection.instance_variable_get("@config")[:database]}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    ActiveRecord::Base.connection.execute('SHOW tables').each do |t|
      execute "ALTER TABLE `#{t[0]}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
      execute "ALTER TABLE `#{t[0]}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    end

  end
end
