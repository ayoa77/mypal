require 'custom_logger'

class GunMailer

	@@av = ActionView::Base.new(ActionController::Base.view_paths)
	@@av.class_eval do
		# include any needed helpers (for the view)
		include ApplicationHelper
		include Rails.application.routes.url_helpers
	end

	def self.send_invitation (from_user, email_to, name_to)
		if EmailSetting.allowed?(email_to, :invitations)
			I18n.with_locale(user_locale(from_user)) do
				send_async_message(
					email_to,
					I18n.t("emails.invite.intro", name: from_user.name),
					"gun_mailer/users/invite",
					{
						from_user: from_user,
						name_to: name_to,
						unsubscribe_token: EmailSetting.getToken(email_to, :invitations)
					}
				)
			end
		end
	end

	def self.send_conversation_reply user_to, message
		if EmailSetting.allowed?(user_to.email, :conversations)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					I18n.t("emails.new_message.intro", name: message.user.name),
					"gun_mailer/conversations/new_message",
					{
						name_to: user_to.name,
						message: message,
						conversation_id: message.conversation.id,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :conversations)
					}
				)
			end
		end
	end

	def self.send_new_like_my_request user_to, request, liker
		Notification.notify(user_to, :request_like, request, liker, request.like_count)
		#no email at this point
	end

	def self.send_new_like_my_comment user_to, comment, liker
		Notification.notify(user_to, :comment_like, comment, liker, comment.like_count)
		#no email at this point
	end

	def self.send_new_comment_my_request user_to, comment
		Notification.notify(user_to, :comment_my_request, comment.request, comment.user, comment.request.comments.map(&:user_id).uniq.count)
		if EmailSetting.allowed?(user_to.email, :comments)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					I18n.t("emails.new_comment.intro", name: comment.user.name),
					"gun_mailer/comments/new_comment_my_request",
					{
						name_to: user_to.name,
						comment: comment,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :comments)
					}
				)
			end
		end
	end

	def self.send_new_comment_commented_request user_to, comment
		Notification.notify(user_to, :comment_commented_request, comment.request, comment.user, comment.request.comments.map(&:user_id).uniq.count)
		if EmailSetting.allowed?(user_to.email, :comments)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					I18n.t("emails.new_comment_commented.intro", name: comment.user.name),
					"gun_mailer/comments/new_comment_commented_request",
					{
						name_to: user_to.name,
						comment: comment,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :recomments)
					}
				)
			end
		end
	end

	def self.send_new_follower user_to, follower
		Notification.notify(user_to, :new_follower, follower, follower)
		if EmailSetting.allowed?(user_to.email, :newfollowers)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					I18n.t("emails.new_follower.intro", name: follower.name),
					"gun_mailer/users/new_follower",
					{
						name_to: user_to.name,
						follower: follower,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :newfollowers)
					}
				)
			end
		end
	end

	def self.send_fresh_new_posts (user_to, requests)
		if EmailSetting.allowed?(user_to.email, :newsletters)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					I18n.t("emails.fresh_new_posts.intro"),
					"gun_mailer/requests/fresh_new_posts",
					{
						name_to: user_to.name,
						requests: requests,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :newsletters)
					}
				)
			end
		end
	end

	def self.send_newsletter (user_to, newsletter)
		if EmailSetting.allowed?(user_to.email, :newsletters)
			I18n.with_locale(user_locale(user_to)) do
				send_async_message(
					user_to.email,
					newsletter.subject,
					"gun_mailer/newsletter",
					{
						name_to: user_to.name,
						newsletter: newsletter,
						unsubscribe_token: EmailSetting.getToken(user_to.email, :newsletters)
					}
				)
			end
		end
	end

	private

		def self.user_locale user
			if user.language.present? && I18n.available_locales.include?(user.language.to_sym)
				return user.language.to_sym
			else
				return I18n.default_locale
			end
		end

    def self.setting the_setting
      if the_setting == "SITE_NAME"
        return setting("CHINA") == "1" ? "小圈" : "globetutoring"
      else
        Setting.find_by(key: the_setting).value
      end
    end

		def self.localized_setting user, setting
			if user.language.present? && I18n.available_locales.include?(user.language.to_sym) && user.language == Setting.find_by(key: 'LOCALE_SECONDARY').value
				return Setting.find_by(key: setting+'_SECONDARY').value
			else
				return Setting.find_by(key: setting+'_PRIMARY').value
			end
		end

		def self.send_async_message to, subject, html_template, locals
			unless Rails.env.production?
				subject = "[to: #{to}] #{subject}"
				to = "ayodeleamadi@gmail.com"
			end
			begin
				settings = {}
		    Setting.all.each do |s|
		      settings[s.key] = s.value
		    end
		    settings["SITE_NAME"] = settings["CHINA"] == "1" ? "小圈" : "globetutoring"
		    locals[:settings] = settings

				locals[:description] = I18n.locale.to_s == settings["LOCALE_SECONDARY"] ? settings["DESCRIPTION_SECONDARY"] : settings["DESCRIPTION_PRIMARY"]

				if Rails.env.production?
					Rails.application.routes.default_url_options[:host] = 'globetutoring.com'
				else
					Rails.application.routes.default_url_options[:host] = 'localhost:3000'
				end

				html_output = @@av.render template: html_template, locals: locals, layout: 'layouts/email'
				from = ENV['MAILGUN_FROM_ADDRESS']
				text = ActionView::Base.full_sanitizer.sanitize( html_output )
				html = html_output.to_str
				Resque.enqueue(EmailJob, from, to, subject, text, html)
			rescue => err
				# Log error
				CustomLogger.add(__FILE__, __method__, {email: { to: to, subject: subject, html_template: html_template, locals: locals}}, err)
			end
		end

		# def self.replace_new_lines_with_br original_text
		# 	original_text.gsub(/(?:\n\r?|\r\n?)/, '<br>')
		# end
end
