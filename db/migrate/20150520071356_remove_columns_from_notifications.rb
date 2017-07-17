class RemoveColumnsFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :user_from_id, :integer
    remove_column :notifications, :action_path
    remove_column :notifications, :message_key
  end
end
