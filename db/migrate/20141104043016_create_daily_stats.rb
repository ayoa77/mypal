class CreateDailyStats < ActiveRecord::Migration
  def change
    create_table :daily_stats do |t|
    	t.date :date
    	t.integer :users
    	t.integer :active_users
    	t.integer :requests
    	t.integer :recent_requests
    	t.integer :finished_meetings
    	t.integer :recent_finished_meetings
    end
    add_index :daily_stats, :date, unique: true
  end
end
