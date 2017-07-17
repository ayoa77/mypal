class CreateConversationsUsers < ActiveRecord::Migration
  def change
    create_table :conversations_users do |t|
      t.integer :conversation_id
      t.integer :user_id
    end
    add_index :conversations_users, :conversation_id
    add_index :conversations_users, :user_id
  end
end
