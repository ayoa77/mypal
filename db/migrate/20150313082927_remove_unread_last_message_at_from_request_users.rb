class RemoveUnreadLastMessageAtFromRequestUsers < ActiveRecord::Migration
  def change
  	remove_column :request_users, :unread, :boolean
  	remove_column :request_users, :last_message_at, :datetime
  end
end
