class AddLastFreshNewPostAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_fresh_new_posts_at, :datetime, after: :last_seen_at
  end
end
