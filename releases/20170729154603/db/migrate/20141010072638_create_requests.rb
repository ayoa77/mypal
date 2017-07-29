class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.string :summary
      t.text :details
      t.decimal :reward, precision: 8, scale: 2, default: 0
      t.boolean :private, default: false
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :requests, :user_id
    add_index :requests, :private
    add_index :requests, :active
    add_index :requests, :updated_at
  end
end
