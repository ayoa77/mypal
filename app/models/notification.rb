# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  notification_type :integer
#  notable_id        :integer
#  notable_type      :string(191)
#  from_user_id      :integer
#  read              :boolean          default("0")
#  done              :boolean          default("0")
#  created_at        :datetime
#  updated_at        :datetime
#  from_user_count   :integer          default("0")
#

class Notification < ActiveRecord::Base
  establish_connection(Rails.env.to_sym) if Setting.find_by(key: "VISIBLE").value != "0"

  
  enum notification_type: { request_like: 1, comment_my_request: 2, comment_commented_request: 3, new_follower: 4, comment_like: 5 }

  belongs_to :user
  belongs_to :from_user, class_name: "User"
  belongs_to :notable, polymorphic: true

  validates_presence_of :user  
  validates_presence_of :from_user
  validates :notification_type, presence: true
  validates_presence_of :notable

  def self.notify(user, ntype, notable, from_user, from_user_count = 1)
    notification = Notification.find_by(user: user, notification_type: Notification.notification_types[ntype], notable: notable) || Notification.create(user: user, notification_type: ntype, notable: notable)

    notification.from_user = from_user
    notification.from_user_count = from_user_count
    notification.updated_at = Time.now
    notification.read = false
    notification.done = false
    notification.save

    Fiber.new do
      WebsocketRails["#{ActiveRecord::Base.connection.current_database}_user_#{user.id}"].trigger(:notification_read_update, { count: Notification.where(user: user, read: false).count })
    end.resume

    #TODO: push unread_notification_count through websocket!
  end
end
