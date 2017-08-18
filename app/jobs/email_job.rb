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
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    end


def self.test
    begin
    RestClient.post "#{Rails.application.secrets.mailgun_base_url}messages",
      from: 'test <ayodeleamadi@mg.globetutoring.com>',
      to: 'ayodeleamadi@gmail.com',
      subject: 'subjectify',
      text: 'textme',
      html: 'htmlme'
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    end
  end
end
