class RemoveColumnsFromRequests < ActiveRecord::Migration
  def change
    rename_column :requests, :title, :content
    remove_column :requests, :description
    remove_column :requests, :reward
    remove_column :requests, :commission
  end
end
