class AddNewFollowersToEmailSettings < ActiveRecord::Migration
  def change
    rename_column :email_settings, :forwards, :invitations
    add_column :email_settings, :newfollowers, :boolean, default: true, after: :recomments
  end
end
