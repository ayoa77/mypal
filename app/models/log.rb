# == Schema Information
#
# Table name: logs
#
#  id      :integer          not null, primary key
#  content :text(65535)
#

class Log < ActiveRecord::Base

  def self.add(content)
    begin
      Log.create(content: {timestamp: Time.now}.merge(content).to_json)
    rescue => err
      ExceptionNotifier.notify_exception(error)
    end
  end

end
