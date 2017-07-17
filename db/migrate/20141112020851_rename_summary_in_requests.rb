class RenameSummaryInRequests < ActiveRecord::Migration
  def change
    rename_column :requests, :summary, :title
    rename_column :requests, :details, :description
    change_column :requests, :reward, :integer, default: 0
  end
end
