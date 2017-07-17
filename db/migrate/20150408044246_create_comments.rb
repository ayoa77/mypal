class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :request_id
      t.integer :user_id
      t.text :content
      t.boolean :enabled, default: true
      t.integer :rating, default: 0
      t.integer :reports, default: 0
      t.timestamps
    end
    add_index :comments, :request_id
  end
end
