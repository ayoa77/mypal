class DropOldTagsTable < ActiveRecord::Migration
  def change
    drop_table :old_tags
    drop_table :requests_tags
  end
end
