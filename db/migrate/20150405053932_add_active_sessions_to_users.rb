class AddActiveSessionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active_sessions, :text, after: :last_seen_at
  end
end
