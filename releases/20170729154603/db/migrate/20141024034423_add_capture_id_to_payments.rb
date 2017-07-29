class AddCaptureIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :capture_id, :string
    add_index :payments, :capture_id
  end
end
