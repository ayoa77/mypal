class AddRelatedIdsToTags < ActiveRecord::Migration
  def change
    add_column :tags, :related_ids, :string
  end
end
