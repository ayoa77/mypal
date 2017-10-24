class ChangeLengthOfSettingsKeys < ActiveRecord::Migration
  def change
  change_column :settings, :value, :string, :limit => 255
  end
end
