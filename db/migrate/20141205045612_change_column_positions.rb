class ChangeColumnPositions < ActiveRecord::Migration
  def change
    change_column :requests, :commission, :decimal, precision: 8, scale: 2, default: 0, after: :reward
    change_column :messages, :system_generated, :boolean, default: false, after: :user_id
    change_column :payments, :capture_id, :string, after: :token
  end
end
