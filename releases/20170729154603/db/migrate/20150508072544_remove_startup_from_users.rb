class RemoveStartupFromUsers < ActiveRecord::Migration
  def change
    change_column :users, :biography, :text
    remove_column :users, :startup
    remove_index :users, name: "index_search"
  end
end
