class AddLastOnlineToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :first_login
    rename_column :users, :last_login, :last_seen_at
    add_column :users, :ip, :string, after: :rank_conversations
  end
end
