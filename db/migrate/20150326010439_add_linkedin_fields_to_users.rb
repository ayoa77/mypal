class AddLinkedinFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :linkedin_url, :string, after: :website
    add_column :users, :linkedin_name, :string, after: :linkedin_url
  end
end
