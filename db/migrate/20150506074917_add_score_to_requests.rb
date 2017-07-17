class AddScoreToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :score, :float, default: 1, after: :comment_count
    add_index :requests, :score
    remove_index :requests, :like_count
  end
end
