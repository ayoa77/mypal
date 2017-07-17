# == Schema Information
#
# Table name: requests
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  subject          :string(191)
#  content          :text(16777215)
#  reward           :text(16777215)
#  location_id      :integer
#  workflow_state   :string(191)
#  user_reach_count :integer          default("0")
#  like_count       :integer          default("0")
#  report_count     :integer          default("0")
#  comment_count    :integer          default("0")
#  raw_score        :integer          default("0")
#  score            :float(24)        default("1")
#  created_at       :datetime
#  updated_at       :datetime
#

require 'gun_mailer'
# require 'elasticsearch/model'
require 'open-uri'
require 'json'

class Request < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  include Rails.application.routes.url_helpers

  acts_as_taggable

  belongs_to :user

  belongs_to :location

  has_many :request_users
  has_many :users, through: :request_users

  has_many :viewings, as: :viewable

  has_many :ratings, as: :rateable
  has_many :likers, -> { where("`ratings`.`rating` = 1").order("`ratings`.`id` DESC") }, through: :ratings, source: :user
  has_many :reporters, -> { where("`ratings`.`rating` = -2").order("`ratings`.`id` DESC") }, through: :ratings, source: :user

  has_many :comments, -> { where(enabled:true)}
  has_many :comment_users, -> { uniq }, through: :comments, source: :user

  validates_presence_of :user  
  validates :subject, presence: true
  validates :content, presence: true

  scope :active, -> { with_active_state }
  scope :not_disabled, -> { where.not workflow_state: 'disabled' }

  scope :top_last_week, -> { where("`requests`.`created_at` >= ?", 7.days.ago).order("`requests`.`raw_score` DESC, `requests`.`score` DESC") }

  before_validation :sanitize_fields

  before_create :set_location

  validate :validate_tags, on: :create

  include Workflow
  workflow do
    state :active do
      event :disable, :transitions_to => :disabled
    end
    state :disabled do
      event :enable, :transitions_to => :active
    end
  end

  def real_subject
    self.subject || (self.content.truncate(80) rescue '?')
  end

  def rate user, rating
    rating_obj = Rating.find_by(user:user, rateable: self) || Rating.new(user:user, rateable: self)
    old_rating = rating_obj.rating || 0
    if rating_obj.update_attributes rating: rating
      
      update_score(:rate)

      diff_rate = rating_obj.rating - old_rating
      User.connection.update "UPDATE `users` SET `request_like_count`=`request_like_count`+#{diff_rate} WHERE `id`=#{self.user.id}" unless diff_rate == 0
      self.user.update_points

      if rating != old_rating && rating_obj.upvote? && self.user != user
        GunMailer.send_new_like_my_request self.user, self, user
      end
      
      # notify on slack about bad requests
      if self.reporters.count == 2
        notifier = Slack::Notifier.new Rails.application.secrets.slack_web_hook
        notifier.ping "A request has received 2 reports, you might want to consider to delete it: <#{request_url(self, host: Setting.find_by(key: "SITE_URL").value.chomp("/") )}|#{self.real_subject}>"
      end
    end
    return rating_obj
  end

  # def recalculate_rating
  #   self.update_columns(like_count: self.likers.count, report_count: self.reporters.count)
  # end

  def update_score(action = nil)
    new_like_count =       action == :rate    || action == :all ? self.likers.count : self.like_count
    new_report_count =     action == :rate    || action == :all ? self.reporters.count : self.report_count
    new_comment_count =    action == :comment || action == :all ? self.users.count-1 : self.comment_count
    new_user_reach_count = action == :view    || action == :all ? self.viewings.count : self.user_reach_count

    new_raw_score = new_like_count + 2 * new_comment_count; 

    new_score = [1, new_raw_score].max.to_f / [1, new_user_reach_count].max

    self.update_columns(like_count: new_like_count, 
                        report_count: new_report_count, 
                        comment_count: new_comment_count, 
                        user_reach_count: new_user_reach_count,
                        raw_score: new_raw_score,
                        score: new_score)
  end

  def recalculate
    old_score = self.score
    self.update_score :all
    if self.score.round(4) != old_score.round(4)
      puts "Request #{self.id} score recalculated: #{old_score.round(4)} => #{self.score.round(4)}"
    end
  end

  private

  def sanitize_fields
    self.content = HTML::FullSanitizer.new.sanitize(self.content) if self.content.present?
    self.reward = HTML::FullSanitizer.new.sanitize(self.reward) if self.reward.present?
  end

  def set_location
    self.location = self.user.location if self.user.location.present?
  end

  def validate_tags
    if tag_list.length > 1
      errors.add("", "Please provide maximum one tag")
    end
    # if content_required? && tag_list.length != 1
    #   errors.add("", "Please provide one tag")
    # end
    # if tag_list.length > 5
    #   errors.add(:tag_list, "Please provide at maximum 5 topics")
    # end
  end

end
