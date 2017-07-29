class DropReferrals < ActiveRecord::Migration
  def change
    drop_table :referrals
  end
end
