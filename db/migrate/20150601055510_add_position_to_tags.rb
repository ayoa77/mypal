class AddPositionToTags < ActiveRecord::Migration
  def change
    add_column :tags, :position, :integer, default: 0, after: :id
    add_index :tags, :position
    remove_index :tags, :user_count
    remove_index :tags, :taggings_count
  end
end
