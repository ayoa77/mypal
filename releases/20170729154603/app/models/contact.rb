# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  source     :integer          default("0")
#  email      :string(191)
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class Contact < ActiveRecord::Base

  enum source: [:manual, :gmail]

  belongs_to :user

  validates :email, presence: true, :uniqueness => {:scope => [:user_id, :source]}, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }

end
