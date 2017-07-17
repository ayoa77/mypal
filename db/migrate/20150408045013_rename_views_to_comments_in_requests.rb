class RenameViewsToCommentsInRequests < ActiveRecord::Migration
  def change
    remove_column :requests, :view_count, :integer, default: 0, after: :reports
    add_column :requests, :comment_count, :integer, default: 0, after: :reports
  end
end
