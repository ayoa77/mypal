class CreateEmailSettings < ActiveRecord::Migration
  def change
    create_table :email_settings do |t|
      t.string :email
      t.boolean :forwards, default: true
      t.boolean :conversations, default: true
      t.boolean :newsletters, default: true
      t.timestamps
    end
    add_index :email_settings, :email
  end
end
