class CreateInvitations < ActiveRecord::Migration
  def change
    drop_table :email_forwards
    remove_column :requests, :email_forward_count
    create_table :invitations do |t|
      t.integer :user_id
      t.string :email
      t.timestamps
    end
    add_index :invitations, [:user_id, :email], unique: true
    add_index :invitations, :email
  end
end
