# == Schema Information
#
# Table name: conversations
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Conversation < ActiveRecord::Base
  acts_as_paranoid
  establish_connection(Rails.env.to_sym) if Setting.find_by(key: "VISIBLE").value != "0"

  has_many :conversation_users
  has_many :users, through: :conversation_users

  has_many :messages

  has_many :ratings, as: :rateable

  def rate user, rating
    rating_obj = Rating.find_by(user:user, rateable: self) || Rating.new(user:user, rateable: self)
    old_rating = rating_obj.rating || 0
    # old_report = rating_obj.report? ? 1 : 0
    if rating_obj.update_attributes rating: rating
      
      # calculate differences compared to previous rating
      diff_rate = rating_obj.rating - old_rating
      # diff_report = (rating_obj.report? ? 1 : 0) - old_report
      
      # update the rating of the other participants in this conversation
      users.each do |u|
        if u != user
          User.connection.update "UPDATE `users` SET `conversation_like_count`=`conversation_like_count`+#{diff_rate} WHERE `id`=#{u.id}" unless diff_rate == 0
          u.update_points
        end
      end
    end
    return rating_obj
  end

  def mark_read(user)
    cu = conversation_users.where(user: user).first
    if cu.present? 
      if cu.unread
        cu.unread = false
        # cu.notified = false # FIXME: we should not need this
        cu.last_read_at = DateTime.now
        cu.save
      elsif cu.last_read_at.nil? || cu.last_read_at < 5.minutes.ago
        #to keep last_read_at more or less up to date without too many updates
        cu.last_read_at = DateTime.now
        cu.save
      end
    end 
  end

end
