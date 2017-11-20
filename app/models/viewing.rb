# == Schema Information
#
# Table name: viewings
#
#  id            :integer          not null, primary key
#  viewable_id   :integer
#  viewable_type :string(191)
#  user_id       :integer
#  view_count    :integer          default("0")
#  created_at    :datetime
#  updated_at    :datetime
#

class Viewing < ActiveRecord::Base
     establish_connection(Rails.env.to_sym) if Setting.find_by(key: "VISIBLE").value != "0"


  belongs_to :user
  belongs_to :viewable, polymorphic: true

end
