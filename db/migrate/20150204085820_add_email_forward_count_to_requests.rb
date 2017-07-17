class AddEmailForwardCountToRequests < ActiveRecord::Migration
  def up
    add_column :requests, :email_forward_count, :integer, default: 0, after: :conversation_count
  end

  def down
    remove_column :requests, :email_forward_count
  end
end
