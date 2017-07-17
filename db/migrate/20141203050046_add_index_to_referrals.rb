class AddIndexToReferrals < ActiveRecord::Migration
  def change
    add_index :referrals, :request_id
  end
end
