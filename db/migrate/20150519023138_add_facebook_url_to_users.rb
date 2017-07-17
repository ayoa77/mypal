class AddFacebookUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_url, :string, after: :linkedin_name
  end
end
