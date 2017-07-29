class AddRatingIndexToRatings < ActiveRecord::Migration
  def change
    add_index :ratings, :rating
  end
end
