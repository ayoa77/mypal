class AddKeywordsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :keywords, :text, after: :active_sessions
  end
end
