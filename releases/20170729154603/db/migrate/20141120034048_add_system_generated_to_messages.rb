class AddSystemGeneratedToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :system_generated, :boolean, default: false
  end
end
