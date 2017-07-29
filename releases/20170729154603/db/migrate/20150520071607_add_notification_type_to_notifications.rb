class AddNotificationTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_type, :integer, after: :user_id
    add_column :notifications, :from_user_id, :integer, after: :notable_type
    add_column :notifications, :from_user_count, :integer,  default: 0, after: :from_user_id
    add_index :notifications, [:user_id, :notification_type, :notable_type, :notable_id], name: "one_notification_per_type", unique: true
    add_index :notifications, :updated_at
  end
end
 