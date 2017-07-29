class RemoveVotesFromRequests < ActiveRecord::Migration
  def change
    rename_column :requests, :rating, :like_count
    rename_column :requests, :reports, :report_count
    remove_column :requests, :votes, :integer

    rename_column :users, :reports, :report_count
    change_column :users, :report_count, :integer, after: :following_count
    rename_column :users, :followers_count, :follower_count

    add_column :users, :request_count, :integer, default: 0, after: :report_count
  end
end
