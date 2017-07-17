class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :payment_id
      t.decimal :amount
      t.references :meeting, index: true
      t.string :redirect_url
      t.string :authorization_id

      t.timestamps
    end
  end
end
