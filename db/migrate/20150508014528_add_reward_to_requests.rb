class AddRewardToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :reward, :string, after: :content_type
  end
end
