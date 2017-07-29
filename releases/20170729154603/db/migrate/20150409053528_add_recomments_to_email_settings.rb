class AddRecommentsToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :recomments, :boolean, default: true, after: :comments
  end
end
