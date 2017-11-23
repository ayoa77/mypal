# == Schema Information
#
# Table name: request_users
#
#  id         :integer          not null, primary key
#  request_id :integer
#  user_id    :integer
#

class RequestUser < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :request

  private

end
