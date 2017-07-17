class ChangeContentInRequests < ActiveRecord::Migration
  def change
    change_column :requests, :content, :text
  end
end
