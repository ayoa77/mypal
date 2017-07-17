class CreateRequestsTags < ActiveRecord::Migration
  def change
    create_table :requests_tags do |t|
      t.integer :request_id
      t.integer :tag_id
    end
    add_index :requests_tags, :request_id
    add_index :requests_tags, :tag_id
  end
end
