class RenameAuthorizationIdToTokenInPayment < ActiveRecord::Migration
  def change
  	rename_column :payments, :authorization_id, :token
  	add_index :payments, :token
  end
end
