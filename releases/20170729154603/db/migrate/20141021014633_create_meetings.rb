class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.integer :conversation_id
      t.datetime :when
      t.string :where
      t.integer :status        
      t.timestamps
    end
    add_index :meetings, :conversation_id
    add_index :meetings, :status
  end
end
