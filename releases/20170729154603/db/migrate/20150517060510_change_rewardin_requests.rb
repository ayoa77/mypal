class ChangeRewardinRequests < ActiveRecord::Migration
  def change
    change_column :requests, :reward, :text
  end
end
