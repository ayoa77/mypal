class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :user_from_id
      t.string  :message_key
      t.string  :action_path
      t.integer :notable_id
      t.string  :notable_type
      t.boolean :read, default: false
      t.boolean :done, default: false
      t.timestamps
    end
    add_index :notifications, [:user_id, :read]
  end
end
