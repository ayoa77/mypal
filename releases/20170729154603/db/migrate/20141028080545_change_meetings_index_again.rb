class ChangeMeetingsIndexAgain < ActiveRecord::Migration
  def change
  	remove_index :meetings, :conversation_id
    add_index :meetings, :conversation_id
  end
end
