class RenameTableConversationsUsers < ActiveRecord::Migration
  def change
    rename_table :conversations_users, :conversation_users
    add_column :conversation_users, :unread, :boolean, default: false
    rename_column :request_users, :unread_messages, :unread
  end
end
