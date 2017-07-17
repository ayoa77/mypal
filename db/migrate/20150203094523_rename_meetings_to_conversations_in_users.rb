class RenameMeetingsToConversationsInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :reputation_meetings, :reputation_conversations
  end
end
