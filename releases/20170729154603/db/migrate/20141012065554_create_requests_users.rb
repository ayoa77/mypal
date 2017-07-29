class CreateRequestsUsers < ActiveRecord::Migration
  def change
    create_table :requests_users do |t|
      t.integer :request_id
      t.integer :user_id
    end
    add_index :requests_users, :request_id
    add_index :requests_users, :user_id
  end
end
