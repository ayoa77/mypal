class AddCommentsToEmailSettings < ActiveRecord::Migration
  def change
    add_column :email_settings, :comments, :boolean, default: true, after: :conversations
  end
end
