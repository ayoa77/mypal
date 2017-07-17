class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :subject
      t.string :intro
      t.text :content
      t.boolean :sent, default: false
      t.timestamps
    end
  end
end
