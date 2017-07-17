class AddIndexToConversations < ActiveRecord::Migration
  def change
    add_index :conversations, :updated_at
  end
end
