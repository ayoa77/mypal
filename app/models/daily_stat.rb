# == Schema Information
#
# Table name: daily_stats
#
#  id                   :integer          not null, primary key
#  date                 :date
#  users                :integer
#  daily_active_users   :integer          default("0")
#  weekly_active_users  :integer          default("0")
#  monthly_active_users :integer
#  requests             :integer
#  recent_requests      :integer
#  conversations        :integer
#  recent_conversations :integer
#

class DailyStat < ActiveRecord::Base

  def self.populate
    puts "#{Time.now.to_s} - Start DailyStat.populate..."
    stat = DailyStat.new
    stat.date = Date.today
    stat.users = User.all.count
    stat.daily_active_users = User.where('last_seen_at >= ?', 24.hours.ago).count
    stat.weekly_active_users = User.where('last_seen_at >= ?', 168.hours.ago).count
    stat.monthly_active_users = User.where('last_seen_at >= ?', Date.today - 30).count
    stat.requests = Request.not_disabled.count
    stat.recent_requests = Request.not_disabled.where('`created_at` >= ?', Date.today - 30).count
    stat.conversations = Conversation.all.count
    stat.recent_conversations = Conversation.where('`created_at` >= ?', Date.today - 30).count

    stat.save
    puts "#{Time.now.to_s} - DailyStat.populate finished"
  end

end
