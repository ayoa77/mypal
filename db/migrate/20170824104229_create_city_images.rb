class CreateCityImages < ActiveRecord::Migration
  def change
    create_table :city_images do |t|
      t.belongs_to :tag, index: true
      t.string :banner_uid
      t.string :small_uid
    end
  end
end
