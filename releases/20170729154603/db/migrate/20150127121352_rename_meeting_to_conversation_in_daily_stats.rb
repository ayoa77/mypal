class RenameMeetingToConversationInDailyStats < ActiveRecord::Migration
  def change
    rename_column :daily_stats, :finished_meetings, :conversations
    rename_column :daily_stats, :recent_finished_meetings, :recent_conversations
  end
end
