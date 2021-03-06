class AddSocketKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :socket_key, :string, after: :active_sessions
    User.all.each do |u|
      u.update_columns(socket_key: SecureRandom.hex)
    end
  end
end
