class AddRatingToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :score, :integer, default: 0, after: :workflow_state
    add_column :requests, :user_reputation, :integer, default: 0, after: :score
  end
end
