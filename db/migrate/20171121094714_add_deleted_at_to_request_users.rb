class AddDeletedAtToRequestUsers < ActiveRecord::Migration
  def change
    add_column :request_users, :deleted_at, :datetime
    add_index :request_users, :deleted_at
  end
end
