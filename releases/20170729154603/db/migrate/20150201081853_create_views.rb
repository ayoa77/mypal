class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.integer :user_id
      t.integer :request_id
    end
    add_index :views, [:user_id, :request_id], unique: true
  end
end
