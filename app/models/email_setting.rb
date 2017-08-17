# == Schema Information
#
# Table name: email_settings
#
#  id            :integer          not null, primary key
#  email         :string(191)
#  invitations   :boolean          default("1")
#  conversations :boolean          default("1")
#  comments      :boolean          default("1")
#  recomments    :boolean          default("1")
#  newfollowers  :boolean          default("1")
#  newsletters   :boolean          default("1")
#  created_at    :datetime
#  updated_at    :datetime
#

class EmailSetting < ActiveRecord::Base

  validates :email, presence: true, uniqueness: true, :format => { :with => /\A[-_a-zA-Z0-9\.%\+]+@([-_a-zA-Z0-9\.]+\.)+[a-z]{2,4}\Z/i }

  def self.getToken(email, setting)
    email_hash = {email: email, setting: setting}
    Base64.urlsafe_encode64(email_hash.to_json)
  end

  def self.processToken(token)
    email_hash = JSON.parse Base64.urlsafe_decode64(token)
    if email_hash.has_key?("email") && email_hash.has_key?("setting")
      setting_obj = EmailSetting.find_by(email: email_hash["email"]) || EmailSetting.new(email: email_hash["email"])
      setting_obj.update_attributes(invitations: false) if email_hash["setting"] == "invitations"
      setting_obj.update_attributes(conversations: false) if email_hash["setting"] == "conversations"
      setting_obj.update_attributes(comments: false) if email_hash["setting"] == "comments"
      setting_obj.update_attributes(recomments: false) if email_hash["setting"] == "recomments"
      setting_obj.update_attributes(newfollowers: false) if email_hash["setting"] == "newfollowers"
      setting_obj.update_attributes(newsletters: false) if email_hash["setting"] == "newsletters"
    end
  end

  def self.allowed?(email, setting)
    setting_obj = EmailSetting.find_by(email: email)
    if setting_obj.present?
      return setting_obj.invitations if setting == :invitations
      return setting_obj.conversations if setting == :conversations
      return setting_obj.comments if setting == :comments
      return setting_obj.recomments if setting == :recomments
      return setting_obj.newfollowers if setting == :newfollowers
      return setting_obj.newsletters if setting == :newsletters
      return false
    else
      return true
    end
  end

end
