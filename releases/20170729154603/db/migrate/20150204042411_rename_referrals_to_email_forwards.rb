class RenameReferralsToEmailForwards < ActiveRecord::Migration
  def change
    rename_table :referrals, :email_forwards
  end
end
