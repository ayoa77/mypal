class AddBookkeepingToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :received, :decimal, precision: 8, scale: 2, default: 0, after: :place
    add_column :meetings, :returned, :decimal, precision: 8, scale: 2, default: 0, after: :received
    add_column :meetings, :paidout, :decimal, precision: 8, scale: 2, default: 0, after: :returned
  end
end
