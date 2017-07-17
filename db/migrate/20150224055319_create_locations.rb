class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city
      t.string :region
      t.string :country
      t.float :lat
      t.float :lng
      t.timestamps
    end
    add_index :locations, [:city, :region, :country], unique: true

    add_column :users, :location_id, :integer, after: :website
    add_index :users, :location_id
  end
end
