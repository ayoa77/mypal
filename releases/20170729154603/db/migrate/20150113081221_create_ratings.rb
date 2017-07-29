class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :rating
      t.references :rateable, polymorphic: true
      t.timestamps  
    end
    add_index :ratings, :user_id
    add_index :ratings, [:user_id,:rateable_type]
    add_index :ratings, [:user_id,:rateable_id,:rateable_type], unique: true, name: "one_person_one_rating"
  end
end
