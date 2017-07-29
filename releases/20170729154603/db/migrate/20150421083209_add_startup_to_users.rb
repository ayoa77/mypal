class AddStartupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :startup, :string, after: :biography
    add_index :users, [:name, :biography, :startup, :linkedin_name, :keywords], type: :fulltext, name: 'index_search'
  end
end
