class AddRawScoreToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :raw_score, :integer, default: 0, after: :comment_count
    add_index :requests, :raw_score
  end
end
