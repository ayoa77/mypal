class RenameLabelInTags < ActiveRecord::Migration
  def change
    rename_column :tags, :label, :display_name
  end
end
