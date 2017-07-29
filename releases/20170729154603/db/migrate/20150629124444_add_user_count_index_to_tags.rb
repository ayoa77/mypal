class AddUserCountIndexToTags < ActiveRecord::Migration
  def change
    add_index :tags, :user_count
  end
end
