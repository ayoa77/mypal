class AddLocationToRequests < ActiveRecord::Migration
  def up
    add_column :requests, :location_id, :integer, after: :description
    add_index :requests, :location_id
  end

  def down
    remove_index :requests, :location_id
    remove_column :requests, :location_id, :integer, after: :description
  end
end
