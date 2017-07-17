class AddPointCountToUsers < ActiveRecord::Migration
  def change
    rename_column :users, :rating_requests, :request_like_count
    rename_column :users, :rating_conversations, :conversation_like_count
    add_column :users, :comment_like_count, :integer, default: 0, after: :request_like_count
    remove_column :users, :rank_total
    remove_column :users, :rank_profile
    remove_column :users, :rank_requests
    remove_column :users, :rank_conversations
    add_column :users, :point_count, :integer, default: 0, after: :conversation_like_count
    add_index :users, :point_count
  end
end
