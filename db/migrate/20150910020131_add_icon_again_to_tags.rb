class AddIconAgainToTags < ActiveRecord::Migration
  def change
    add_column :tags, :icon, :string, after: :display_name, default: "hash"
  end
end
