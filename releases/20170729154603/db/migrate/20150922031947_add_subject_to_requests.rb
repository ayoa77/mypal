class AddSubjectToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :project, :string, after: :user_id
    add_column :requests, :subject, :string, after: :project
    remove_column :requests, :content_type, :integer, after: :content
  end
end
