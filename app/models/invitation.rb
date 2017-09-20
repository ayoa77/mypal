# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  email      :string(191)
#  created_at :datetime
#  updated_at :datetime
#

# require 'elasticsearch/model'

class Invitation < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  belongs_to :user

  validates_presence_of :user

  validates :email, presence: true, :uniqueness => {:scope => :user_id}, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }

  def self.invite(user_from, email_to, name_to = nil)
    invite = Invitation.create(user: user_from, email: email_to)
    if invite.present? && invite.valid?
      byebug
      GunMailer.send_invitation(user_from, email_to, name_to)
    end
  end

end
