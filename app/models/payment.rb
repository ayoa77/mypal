# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  payment_id   :string(191)
#  amount       :decimal(10, )
#  meeting_id   :integer
#  redirect_url :string(191)
#  token        :string(191)
#  capture_id   :string(191)
#  created_at   :datetime
#  updated_at   :datetime
#

class Payment < ActiveRecord::Base

  # belongs_to :meeting

  # validates_presence_of :meeting
end
