class AddReportsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :reports, :integer, default: 0, after: :rating
  end
end
