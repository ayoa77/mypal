class RenameWhenWhereInMeetings < ActiveRecord::Migration
  def change
    rename_column :meetings, :when, :moment
    rename_column :meetings, :where, :place
    add_index :meetings, :moment
  end
end
