class AddProposedAtToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :proposed_at, :datetime, after: :created_at
  end
end
