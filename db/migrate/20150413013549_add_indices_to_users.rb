class AddIndicesToUsers < ActiveRecord::Migration
  def change
    add_index :users, :created_at
    add_index :users, :online
    add_index :users, :last_seen_at
  end
end
