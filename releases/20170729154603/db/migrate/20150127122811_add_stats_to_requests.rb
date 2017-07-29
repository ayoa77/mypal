class AddStatsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :view_count, :integer, default: 0, after: :workflow_state
    add_column :requests, :conversation_count, :integer, default: 0, after: :view_count
  end
end
