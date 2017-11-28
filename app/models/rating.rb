# == Schema Information
#
# Table name: ratings
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  rating        :integer
#  rateable_id   :integer
#  rateable_type :string(191)
#  created_at    :datetime
#  updated_at    :datetime
#

class Rating < ActiveRecord::Base
  acts_as_paranoid
  
  # if Setting.find_by(key: "VISIBLE").value != "0"
  #   establish_connection(Rails.env.to_sym) 
  # end

  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates_presence_of :user
  validates_presence_of :rating
  validates_presence_of :rateable
  validates_uniqueness_of :user_id, :scope => [:rateable_id, :rateable_type]
  validates_inclusion_of :rating, in: [-2, -1, 0, 1]

  validate :no_self_rating

  def upvote?
    rating == 1
  end

  def downvote?
    rating == -1
  end

  def vote?
    upvote? || downvote?
  end

  def report?
    rating == -2
  end

  def no_self_rating
    if rateable_type == "Conversation" && !rateable.users.include?(self.user)
      errors.add('', 'Unable to rate a conversation you are not part of')
    end
    if rateable_type == "User" && self.user == rateable
      errors.add('', 'Cannot follow yourself')
    end
    if downvote? && (rateable_type == "User" || rateable_type == "Request" || rateable_type == "Comment")
      errors.add('', 'Cannot downvote this')
    end
  end

end
