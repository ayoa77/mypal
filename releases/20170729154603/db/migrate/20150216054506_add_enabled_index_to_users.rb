class AddEnabledIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :enabled
  end
end
