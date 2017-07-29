class RenameTableRequestsUsers < ActiveRecord::Migration
  def change
  	rename_table :requests_users, :request_users
  	add_column :request_users, :last_message_at, :datetime
    add_column :request_users, :unread_messages, :boolean, default: false
  	add_index :request_users, :last_message_at
  end
end
