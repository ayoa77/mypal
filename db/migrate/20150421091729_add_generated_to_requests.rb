class AddGeneratedToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :content_type, :integer, after: :content, default: 0
    add_index :requests, :content_type
  end
end
