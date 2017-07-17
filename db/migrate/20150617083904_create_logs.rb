class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :content
    end
    add_index :logs, [:content], type: :fulltext, name: 'index_search'
  end
end
