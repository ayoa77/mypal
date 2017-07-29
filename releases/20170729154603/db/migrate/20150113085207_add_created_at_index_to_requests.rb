class AddCreatedAtIndexToRequests < ActiveRecord::Migration
  def change
    remove_index :requests, :updated_at
    add_index :requests, :created_at
  end
end
