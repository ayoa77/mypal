class AddAvatarUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_uid, :string, after: :biography
  end
end
