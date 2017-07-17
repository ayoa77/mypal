class AddLabelsToTags < ActiveRecord::Migration
  def change
    add_column :tags, :label_primary, :string, after: :name
    add_column :tags, :label_secondary, :string, after: :label_primary
  end
end
