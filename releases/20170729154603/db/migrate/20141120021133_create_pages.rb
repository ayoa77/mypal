class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :key
      t.boolean :private, default: false
      t.string :header
      t.string :subheader
      t.text :content
    	t.timestamps
    end
    add_index :pages, :key, unique: true
    add_index :pages, :private
  end
end
