class AddCodesToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :region_code, :string, after: :country
    add_column :locations, :country_code, :string, after: :region_code
  end
end
