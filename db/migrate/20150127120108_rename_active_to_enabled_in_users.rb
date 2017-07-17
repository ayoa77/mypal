class RenameActiveToEnabledInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :active, :enabled
  end
end
