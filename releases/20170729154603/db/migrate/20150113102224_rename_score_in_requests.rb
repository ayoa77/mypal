class RenameScoreInRequests < ActiveRecord::Migration
  def change
    rename_column :requests, :score, :rating
    rename_column :requests, :user_reputation, :reputation
    add_index :requests, :rating
  end
end
