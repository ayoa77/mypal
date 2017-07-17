class AddOnlineToUsers < ActiveRecord::Migration
  def change
    add_column :users, :online, :boolean, after: :ip, default: false
  end
end
