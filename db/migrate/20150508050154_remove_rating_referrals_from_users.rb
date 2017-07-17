class RemoveRatingReferralsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :rating_referrals
    remove_column :users, :rank_referrals
  end
end
