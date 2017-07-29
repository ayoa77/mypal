class AddUnreadIndexes < ActiveRecord::Migration
  def change
    add_index :request_users, :unread
    add_index :conversation_users, :unread 
  end
end
