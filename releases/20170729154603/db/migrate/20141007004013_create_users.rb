class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :biography
      t.string :paypal
      t.boolean :active, default: true
      t.boolean :admin, default: false
      t.datetime :first_login
      t.datetime :last_login
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
