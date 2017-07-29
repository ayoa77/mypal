class AddRequestIdToTags < ActiveRecord::Migration
  def change
    add_column :tags,  :request_id, :integer, after: :user_id
  end
end
