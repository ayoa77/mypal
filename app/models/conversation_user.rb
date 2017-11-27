# == Schema Information
#
# Table name: conversation_users
#
#  id              :integer          not null, primary key
#  conversation_id :integer
#  user_id         :integer
#  unread          :boolean          default("0")
#  last_read_at    :datetime
#  notified        :boolean          default("0")
#

require 'gun_mailer'

class ConversationUser < ActiveRecord::Base
  acts_as_paranoid

  if Setting.find_by(key: "VISIBLE").value != "0"
    establish_connection(Rails.env.to_sym) 
  end
  
  belongs_to :user
  belongs_to :conversation

  before_create :set_last_read_now

  private
  
  def set_last_read_now
    self.last_read_at = DateTime.now
  end

  def self.notify_about_unread_messages
    unread_conversations = ConversationUser.where(unread: true, notified: false).where( "last_read_at < ?" , Time.now - 1.hour)
    unread_conversations.each do |conversation_user|
    	conversation = conversation_user.conversation
  		message = conversation.messages.where(system_generated: false).where("user_id != ?", conversation_user.user_id).where( "updated_at > ?", conversation_user.last_read_at ).first
      if message.nil?
        message = conversation.messages.where(system_generated: false).where("user_id != ?", conversation_user.user_id).last
      end
      if message.present?
      	GunMailer.send_conversation_reply conversation_user.user, message
      	conversation_user.update_attributes( notified: true )
      end
    end
  end

end
