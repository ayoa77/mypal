class RenameTableRequestViews < ActiveRecord::Migration
  def change
    rename_table :views, :request_views
    add_column :request_views, :view_count, :integer, default: 0
    add_column :request_views, :created_at, :datetime
    add_column :request_views, :updated_at, :datetime
    ActiveRecord::Base.connection.update("UPDATE `request_views` SET `view_count` = 1")
    ActiveRecord::Base.connection.update("UPDATE `request_views` SET `created_at` = UTC_TIMESTAMP()")
    ActiveRecord::Base.connection.update("UPDATE `request_views` SET `updated_at` = UTC_TIMESTAMP()")
  end
end
