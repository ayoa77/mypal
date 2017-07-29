class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :count, default: 0
    end
    add_index :tags, :name, unique: true
    add_index :tags, :count
  end
end
