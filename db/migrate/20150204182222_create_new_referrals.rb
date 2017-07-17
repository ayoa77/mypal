class CreateNewReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :user_id
      t.references :result, polymorphic: true
      t.timestamps  
    end
    add_index :referrals, :user_id
    add_index :referrals, :result_type
    add_index :referrals, :created_at
  end
end
