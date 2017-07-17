class AddUniqueEmailIndexToEmailSettings < ActiveRecord::Migration
  def change
    remove_index :email_settings, :email
    add_index :email_settings, :email, unique: true
  end
end
