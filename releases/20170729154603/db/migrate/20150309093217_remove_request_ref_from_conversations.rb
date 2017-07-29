class RemoveRequestRefFromConversations < ActiveRecord::Migration
  def change
    remove_reference :conversations, :request, index: true
  end
end
