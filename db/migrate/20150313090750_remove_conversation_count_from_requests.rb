class RemoveConversationCountFromRequests < ActiveRecord::Migration
  def change
  	remove_column :requests, :conversation_count, :integer
  end
end
