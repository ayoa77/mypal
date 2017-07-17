class AddFollowerIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :following_ids_first_degree, :text, after: :last_seen_at
    add_column :users, :following_ids_second_degree, :text, after: :following_ids_first_degree

  end
end
