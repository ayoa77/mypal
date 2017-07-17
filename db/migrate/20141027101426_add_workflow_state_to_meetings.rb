class AddWorkflowStateToMeetings < ActiveRecord::Migration
  def change
  	remove_column :meetings, :state
  	add_column :meetings, :workflow_state, :string, after: :place
    add_index :meetings, :workflow_state
  end
end
