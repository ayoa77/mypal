class AddMoreActiveUsersToDailyStats < ActiveRecord::Migration
  def change
    rename_column :daily_stats, :active_users, :monthly_active_users
    add_column :daily_stats, :daily_active_users, :integer, default: 0, after: :users
    add_column :daily_stats, :weekly_active_users, :integer, default: 0, after: :daily_active_users

    
  end
end
