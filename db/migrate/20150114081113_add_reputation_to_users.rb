class AddReputationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reputation_total, :integer, default: 0, after: :admin
    add_column :users, :reputation_ratings, :integer, default: 0, after: :reputation_total
    add_column :users, :reputation_requests, :integer, default: 0, after: :reputation_ratings
    add_column :users, :reputation_conversations, :integer, default: 0, after: :reputation_requests
    add_column :users, :reputation_meetings, :integer, default: 0, after: :reputation_conversations
    add_index :users, :reputation_total
  end
end
