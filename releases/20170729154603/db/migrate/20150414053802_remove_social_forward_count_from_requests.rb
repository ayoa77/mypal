class RemoveSocialForwardCountFromRequests < ActiveRecord::Migration
  def change
    remove_column :requests, :social_forward_count
  end
end
