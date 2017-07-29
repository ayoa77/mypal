class SimplifyTagsModel < ActiveRecord::Migration
  def change
      remove_column :tags, :position
      rename_column :tags, :label_primary, :label
      remove_column :tags, :label_secondary
      remove_column :tags, :icon
      add_index :tags, :label
  end
end
