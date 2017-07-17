class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :conversation_id
      t.integer :user_id
      t.text :content
      t.timestamps
    end
    add_index :messages, :conversation_id
    add_index :messages, :user_id
  end
end
