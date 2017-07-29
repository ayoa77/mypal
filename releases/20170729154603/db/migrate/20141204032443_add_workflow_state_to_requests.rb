class AddWorkflowStateToRequests < ActiveRecord::Migration
  def change
    remove_column :requests, :private, :boolean
    remove_column :requests, :active, :boolean
    add_column :requests, :workflow_state, :string, after: :reward
    add_index :requests, :workflow_state
  end
end
