class AddIndicesToTags < ActiveRecord::Migration
  def change
    add_index :tags, :taggings_count
    add_index :tags, :user_count
  end
end
