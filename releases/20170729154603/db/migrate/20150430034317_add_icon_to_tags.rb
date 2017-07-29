class AddIconToTags < ActiveRecord::Migration
  def change
    add_column :tags, :icon, :string, after: :name
  end
end
