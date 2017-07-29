class RemoveProjectFromRequests < ActiveRecord::Migration
  def change
    remove_column :requests, :project, :string, after: :user_id
  end
end
