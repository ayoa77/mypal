# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  email                   :string(191)
#  name                    :string(191)
#  biography               :text(16777215)
#  avatar_uid              :string(191)
#  language                :string(191)
#  paypal                  :string(191)
#  website                 :string(191)
#  linkedin_url            :string(191)
#  linkedin_name           :string(191)
#  facebook_url            :string(191)
#  facebook_name           :string(191)
#  location_id             :integer
#  enabled                 :boolean          default("1")
#  admin                   :boolean          default("0")
#  follower_count          :integer          default("0")
#  following_count         :integer          default("0")
#  report_count            :integer          default("0")
#  request_count           :integer          default("0")
#  request_like_count      :integer          default("0")
#  comment_like_count      :integer          default("0")
#  conversation_like_count :integer          default("0")
#  point_count             :integer          default("0")
#  ip                      :string(191)
#  online                  :boolean          default("0")
#  last_seen_at            :datetime
#  last_fresh_new_posts_at :datetime
#  active_sessions         :text(16777215)
#  socket_key              :string(191)
#  keywords                :text(16777215)
#  created_at              :datetime
#  updated_at              :datetime
#

require 'elasticsearch/model'
require 'custom_logger'
require 'gun_mailer'

class User < ActiveRecord::Base
  include Elasticsearch::Model
  establish_connection(Rails.env.to_sym) if Setting.find_by(key: "VISIBLE").value != "0"

  after_save    { Resque.enqueue(UserIndexJob, :index, self.id, ActiveRecord::Base.connection.current_database) }
  after_destroy { Resque.enqueue(UserIndexJob, :delete, self.id, ActiveRecord::Base.connection.current_database) }

  def as_indexed_json(options={})
    as_json(only: [:name, :linkedin_name, :facebook_name, :biography, :keywords])
  end

  acts_as_taggable

  dragonfly_accessor :avatar do
    copy_to(:avatar){ |a|
      new_size = [a.width, a.height].min
      a.thumb("#{new_size}x#{new_size}#")
    }
  end

  serialize :active_sessions, Array

  validates :email, presence: true, uniqueness: true, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }
  validates :name, presence: true, length: {maximum: 40}
  validates :paypal, allow_blank: true, length: {maximum: 191}, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }
  validates :website, allow_blank: true, length: {maximum: 191}

  validate :private_and_invited, :on => :create

  belongs_to :location

  has_many :requests # requests posted by this user

  has_many :viewings

  has_many :request_users
  has_many :involved_requests, through: :request_users, source: :request # requests posted by this user as well as requests this user replied to

  has_many :conversation_users
  has_many :conversations, through: :conversation_users

  # has_many :request_views
  # has_many :viewed_requests, through: :request_views, source: :request

  has_many :ratings, as: :rateable
  has_many :my_ratings, class_name: "Rating", source: :user

  has_many :followers, -> { where("`ratings`.`rating` = 1").order("`ratings`.`id` DESC") }, through: :ratings, source: :user
  has_many :reporters, -> { where("`ratings`.`rating` = -2").order("`ratings`.`id` DESC") }, through: :ratings, source: :user

  has_many :following, -> {where ("`ratings`.`rating` = 1") }, through: :my_ratings, source: :rateable, source_type: "User"

  has_many :contacts

  has_many :invitations

  has_many :notifications

  has_one :email_setting, primary_key: :email, foreign_key: :email
  accepts_nested_attributes_for :email_setting, update_only: true

  before_validation :sanitize_fields

  after_create :initialize_new_user

  def log_activity ip
    if ip != self.ip
      self.update_columns(ip: ip, last_seen_at: Time.now)
      Resque.enqueue(UserLocationJob, self.id, ActiveRecord::Base.connection.current_database)
    else
      self.update_columns(last_seen_at: Time.now)
    end
  end

  def gravatar
    Digest::MD5.hexdigest(email)
  end

  def super_admin?
    self.email.end_with?("@globetutoring.com") || self.email.end_with?("@skillster.me") || self.email.end_with?("@mypal.co") || self.email == "ayodeleamadi@gmail.com" || self.email == "nathan.wade@murraystate.edu"|| self.email == "chieflinkist@gmail.com" || self.email == "christian_martin@gmx.net" || self.email == "alexfrankish@gmail.com" ||  self.email == "me@steveleggat.com" || self.email == "rkfong88@gmail.com"

  end

  def update_points
    self.reload
    self.update_columns(point_count: self.follower_count + (2*self.request_like_count) + (5*self.comment_like_count) + (10*self.conversation_like_count))
  end

  def recalculate
    new_rating_conversations = 0
    self.conversations.each do |c|
      c.ratings.each do |r|
        if r.user != self
          new_rating_conversations += r.rating
        end
      end
    end
    self.update_columns(follower_count: self.followers.count, following_count: self.following.count, report_count: self.reporters.count, request_count: self.requests.active.count)
    self.update_columns(request_like_count: self.requests.sum(:like_count), conversation_like_count: new_rating_conversations)

    old_point_count = self.point_count
    self.update_points
    if self.point_count != old_point_count
      puts "User #{self.id} points recalculated: #{old_point_count} => #{self.point_count}"
    end
  end

  def rate user, rating
    rating_obj = Rating.find_by(user:user, rateable: self) || Rating.new(user:user, rateable: self)
    old_rating = rating_obj.rating
    if rating_obj.update_attributes rating: rating

      self.update_columns(follower_count: self.followers.count, report_count: self.reporters.count)
      self.update_points
      user.update_columns(following_count: user.following.count)

      if rating != old_rating && rating_obj.upvote?
        GunMailer.send_new_follower self, user
      end

      # notify on slack about bad requests
      if self.reporters.count == 6
        notifier = Slack::Notifier.new Rails.application.secrets.slack_web_hook
        notifier.ping "@sleggat: A user has received 6 reports, you might want to consider to disable it: <#{admin_user_url(self)}|#{self.name}>"
      end
    end
    return rating_obj
  end

  def activate_session(id)
    unless active_sessions.include?(id)
      active_sessions.push(id)
      save
    end
  end

  def deactivate_session(id)
    if active_sessions.include?(id)
      active_sessions.delete(id)
      save
    end
  end

  def send_fresh_new_posts
    tag_ids = self.tags.map(&:id)
    following_user_ids = [self.id] + self.following.map(&:id)

    from_time = 14.days.ago
    from_time = self.last_fresh_new_posts_at if self.last_fresh_new_posts_at.present? && self.last_fresh_new_posts_at > from_time
    from_time = self.created_at if self.created_at.present? && self.created_at > from_time

    requests = Request.where("`requests`.`created_at` > ? && `requests`.`user_id` != ?", from_time, self.id)
    requests = requests.joins("LEFT JOIN `taggings` ON `taggings`.`taggable_id` = `requests`.`id` AND `taggings`.`taggable_type` = 'Request'").where('`taggings`.`tag_id` IN (?) OR `requests`.`user_id` IN (?)', tag_ids, following_user_ids).distinct
    requests = requests.order("`requests`.`score` DESC")
    requests = requests.limit(5).includes(:user, :tags)

    if requests.length >= 3
      GunMailer.send_fresh_new_posts self, requests
      self.update_columns(last_fresh_new_posts_at: Time.now)
    end
  end

  def populate_keywords
    keywords = ""
    if self.location
      keywords += "#{self.location.city || ''} #{self.location.region || ''} #{self.location.country || ''} "
    end
    keywords = keywords.humanize.squeeze
    self.update_columns(keywords: keywords)
  end

  private
  def initialize_new_user
    if !self.avatar_uid.present?
      begin
        self.avatar_url = "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}?s=512&d=mm"
      rescue
        self.avatar = Dragonfly.app.fetch_file("public/default-user-icon.jpg")
      end
    end

    if Setting.find_by(key: "ADMIN_EMAIL").value == self.email
      self.admin = true
    end
    ActsAsTaggableOn::Tag.all.each do |tag|
      self.tag_list.add tag.name
    end
    self.socket_key = SecureRandom.hex
    self.save
    self.reload
    self.tags.each do |t|
      t.populate
    end
    #auto-follow users who invited me
    Invitation.where(email: email).each do |i|
      i.user.rate self, 1
    end
  end


  def private_and_invited
    # if Setting.find_by(key: "PRIVATE").value == "0"
    if Setting.find_by(key: "PRIVATE").value == "1"
      errors.add(:email, "not invited") unless Invitation.find_by(email: email) || Setting.find_by(key: "ADMIN_EMAIL").value == email
  end
end

  def sanitize_fields
    self.name = HTML::FullSanitizer.new.sanitize(self.name) if self.name.present?
    self.email = self.email.downcase.strip if self.email.present?
    self.paypal = self.paypal.downcase.strip if self.paypal.present?
    if self.website.present?
      unless self.website[/\Ahttp:\/\//] || self.website[/\Ahttps:\/\//]
        self.website = "http://#{self.website}"
      end
    end
    self.biography = HTML::FullSanitizer.new.sanitize(self.biography) if self.biography.present?
  end
end
