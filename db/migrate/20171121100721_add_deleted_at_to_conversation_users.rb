class AddDeletedAtToConversationUsers < ActiveRecord::Migration
  def change
    add_column :conversation_users, :deleted_at, :datetime
    add_index :conversation_users, :deleted_at
  end
end
