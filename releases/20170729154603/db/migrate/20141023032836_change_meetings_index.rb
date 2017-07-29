class ChangeMeetingsIndex < ActiveRecord::Migration
  def change
    remove_index :meetings, :conversation_id
    add_index :meetings, :conversation_id, unique: true
  end
end
