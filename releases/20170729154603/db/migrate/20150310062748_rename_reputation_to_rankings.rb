class RenameReputationToRankings < ActiveRecord::Migration
  def change
    remove_column :requests, :reputation
    rename_column :users, :reputation_total, :rank_total
    rename_column :users, :reputation_profile, :rank_profile
    rename_column :users, :reputation_requests, :rank_requests
    rename_column :users, :reputation_referrals, :rank_referrals
    rename_column :users, :reputation_conversations, :rank_conversations
    add_column :users, :rating_requests, :integer, default: 0, after: :rating
    add_column :users, :rating_referrals, :integer, default: 0, after: :rating_requests
    add_column :users, :rating_conversations, :integer, default: 0, after: :rating_referrals
  end
end
