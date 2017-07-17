class AddCommissionToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :commission, :decimal, precision: 8, scale: 2, default: 0
  end
end
