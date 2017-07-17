class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :request_id
      t.timestamps
    end
    add_index :conversations, :request_id
  end
end
