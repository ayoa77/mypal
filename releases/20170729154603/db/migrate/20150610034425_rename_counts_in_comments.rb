class RenameCountsInComments < ActiveRecord::Migration
  def change
    rename_column :comments, :rating, :like_count
    rename_column :comments, :reports, :report_count
  end
end
