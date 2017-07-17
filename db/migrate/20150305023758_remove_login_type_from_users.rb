class RemoveLoginTypeFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :login_type, :string
  end
end
