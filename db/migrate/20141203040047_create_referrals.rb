class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :user_id
      t.integer :request_id
      t.string :email
      t.timestamps
    end
    add_index :referrals, [:user_id, :request_id, :email], unique: true
    add_index :referrals, :email
  end
end
