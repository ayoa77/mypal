class AddUserReachCountToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :user_reach_count, :integer, default: 0, after: :workflow_state
  end
end
