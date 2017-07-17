class AddVotesToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :votes, :integer, default: 0, after: :rating
  end
end
