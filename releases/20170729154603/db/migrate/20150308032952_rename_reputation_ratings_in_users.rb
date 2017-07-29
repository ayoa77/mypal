class RenameReputationRatingsInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :reputation_ratings, :reputation_profile
    add_column :users, :rating, :integer, default: 0, after: :admin
    add_column :users, :reports, :integer, default: 0, after: :rating
  end
end
