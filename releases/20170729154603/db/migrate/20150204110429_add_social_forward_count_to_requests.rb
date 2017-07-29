class AddSocialForwardCountToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :social_forward_count, :integer, default: 0, after: :conversation_count
  end
end
