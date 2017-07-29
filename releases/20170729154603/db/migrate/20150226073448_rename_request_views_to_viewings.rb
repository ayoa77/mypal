class RenameRequestViewsToViewings < ActiveRecord::Migration
  def change
    remove_index :request_views, [:user_id, :request_id]
    rename_column :request_views, :request_id, :viewable_id
    add_column :request_views, :viewable_type, :string, after: :viewable_id
    add_index :request_views, :user_id
    add_index :request_views, [:viewable_id, :viewable_type, :user_id], unique: true
    change_column :request_views, :user_id, :integer, after: :viewable_type
    rename_table :request_views, :viewings
    ActiveRecord::Base.connection.update("UPDATE `viewings` SET `viewable_type` = 'Request'")
  end
end
