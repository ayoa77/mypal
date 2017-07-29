class RenameStatusInMeetings < ActiveRecord::Migration
  def change
    rename_column :meetings, :status, :state
  end
end
