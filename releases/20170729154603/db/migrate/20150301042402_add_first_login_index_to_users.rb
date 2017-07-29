class AddFirstLoginIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :first_login
  end
end
