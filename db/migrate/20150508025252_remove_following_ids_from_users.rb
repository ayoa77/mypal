class RemoveFollowingIdsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :following_ids_first_degree
    remove_column :users, :following_ids_second_degree
  end
end
