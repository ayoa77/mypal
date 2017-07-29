class AddIndexToSettings < ActiveRecord::Migration
  def change
    add_index :settings, :key, unique: true
  end
end
