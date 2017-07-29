class ChangeJoinIndices < ActiveRecord::Migration
  def change
    remove_index :requests_users, :request_id
    remove_index :requests_tags, :request_id
    remove_index :conversations_users, :conversation_id
    add_index :requests_users, [:request_id, :user_id], unique: true
    add_index :requests_tags, [:request_id, :tag_id], unique: true
    add_index :conversations_users, [:conversation_id, :user_id], unique: true
  end
end
