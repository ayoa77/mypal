class AddUserIdToTags < ActiveRecord::Migration
  def change
    add_column :tags,  :user_id, :integer, after: :display_name
  end
end
