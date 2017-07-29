class AddLastReadAtToConversationUsers < ActiveRecord::Migration
  def change
    add_column :conversation_users, :last_read_at, :datetime
    add_column :conversation_users, :notified, :boolean, default: false
    add_index :conversation_users, :notified
  end
end
