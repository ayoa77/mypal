class AddFacebookNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_name, :string, after: :facebook_url
  end
end
