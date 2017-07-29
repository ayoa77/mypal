# == Schema Information
#
# Table name: request_users
#
#  id         :integer          not null, primary key
#  request_id :integer
#  user_id    :integer
#

class RequestUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :request

  private

end
