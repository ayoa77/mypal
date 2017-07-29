class RenameReputationConversationUsers < ActiveRecord::Migration
  def change
    rename_column :users, :reputation_conversations, :reputation_referrals
  end
end
