# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

env :PATH, ENV['PATH']

set :output, "/home/deploy/log/cron_log.log"

every 1.day, :at => '1:00 pm' do # UTC time
  rake "db:populate_daily_stats"
  # rake "db:recalculate"
end

every :monday, :at => '3pm', :roles => [:live] do # UTC time
  rake "users:send_fresh_new_posts"
end

every :wednesday, :at => '3pm', :roles => [:live] do # UTC time
  rake "users:send_fresh_new_posts"
end

every :friday, :at => '3pm', :roles => [:live] do # UTC time
  rake "users:send_fresh_new_posts"
end

every 1.day, :at => '1:00 pm', :roles => [:live] do
  rake "-s sitemap:refresh"
end

every 30.minutes do
  rake "conversations:notify_unread"
end

