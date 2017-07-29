class AddFollowerCountToUsers < ActiveRecord::Migration
  def change
    rename_column :users, :rating, :followers_count
    add_column :users, :following_count, :integer, default: 0, after: :followers_count
  end
end
