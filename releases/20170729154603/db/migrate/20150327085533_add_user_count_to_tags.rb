class AddUserCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :user_count, :integer, default: 0
  end
end
