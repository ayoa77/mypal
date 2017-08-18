require 'gun_mailer'

class EmailJob
  @queue = :email

  def self.perform(from, to, subject, text, html)
    RestClient.post "#{Rails.application.secrets.mailgun_base_url}messages",
      from: from,
      to: to,
      subject: subject,
      text: text,
      html: html
  end
end
