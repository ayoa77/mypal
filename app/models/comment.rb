# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  request_id   :integer
#  user_id      :integer
#  content      :text(16777215)
#  enabled      :boolean          default("1")
#  like_count   :integer          default("0")
#  report_count :integer          default("0")
#  created_at   :datetime
#  updated_at   :datetime
#

class Comment < ActiveRecord::Base

  belongs_to :request
  belongs_to :user
  
  validates_presence_of :request
  validates_presence_of :user  

  validates :content, presence: true

  has_many :ratings, as: :rateable
  has_many :likers, -> { where("`ratings`.`rating` = 1").order("`ratings`.`id` DESC") }, through: :ratings, source: :user
  has_many :reporters, -> { where("`ratings`.`rating` = -2").order("`ratings`.`id` DESC") }, through: :ratings, source: :user


  def rate user, rating
    rating_obj = Rating.find_by(user:user, rateable: self) || Rating.new(user:user, rateable: self)
    old_rating = rating_obj.rating || 0
    if rating_obj.update_attributes rating: rating
      
      update_score(:rate)

      diff_rate = rating_obj.rating - old_rating

      User.connection.update "UPDATE `users` SET `comment_like_count`=`comment_like_count`+#{diff_rate} WHERE `id`=#{self.user.id}" unless diff_rate == 0
      self.user.update_points

      if rating != old_rating && rating_obj.upvote? && self.user != user
        GunMailer.send_new_like_my_comment self.user, self, user
      end
      
      # notify on slack about bad requests
      if self.reporters.count == 2
        notifier = Slack::Notifier.new Rails.application.secrets.slack_web_hook
        notifier.ping "@sleggat: A comment has received 2 reports, you might want to consider to delete it: <#{request_url(self.request)}|#{self.content.truncate(140)}>"
      end
    end
    return rating_obj
  end

  def update_score(action = nil)
    new_like_count =       action == :rate    || action == :all ? self.likers.count : self.like_count
    new_report_count =     action == :rate    || action == :all ? self.reporters.count : self.report_count

    self.update_columns(like_count: new_like_count, 
                        report_count: new_report_count)
  end

end
