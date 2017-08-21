class Admin::DashboardController < AdminController

  def index
    @user_count = User.all.count
    @monthly_active_user_count = User.where('last_seen_at >= ?', Date.today - 30).count
    @weekly_active_user_count = User.where('last_seen_at >= ?', 168.hours.ago).count
    @daily_active_user_count = User.where('last_seen_at >= ?', 24.hours.ago).count
    @online_user_count = User.where(online: true).count

    @request_count = Request.not_disabled.count
    @recent_request_count = Request.not_disabled.where('`created_at` >= ?', Date.today - 30).count

    @conversation_count = Conversation.all.count
    @recent_conversation_count = Conversation.where('`created_at` >= ?', Date.today - 30).count

    # @cities_count = Category.all.count
    # @recent_cities_count = Category.where('`created_at` >= ?', Date.today - 30).count


    @daily_stats = DailyStat.order(id: :desc)

    @new_daily_stats = ActiveRecord::Base.connection.execute("SELECT created, SUM(users), SUM(posts), SUM(updates), SUM(comments), SUM(messages) FROM (SELECT DATE(created_at) created, COUNT(*) users, 0 posts, 0 updates, 0 comments, 0 messages FROM users GROUP BY created UNION ALL SELECT DATE(created_at) created, 0 users, COUNT(*) posts, 0 updates, 0 comments, 0 messages FROM requests WHERE workflow_state != 'disabled' GROUP BY created UNION ALL SELECT DATE(created_at) created, 0 users, 0 posts, COUNT(*) updates, 0 comments, 0 messages FROM requests WHERE workflow_state != 'disabled' GROUP BY created UNION ALL SELECT DATE(created_at) created, 0 users, 0 posts, 0 updates, COUNT(*) comments, 0 messages FROM comments GROUP BY created UNION ALL SELECT DATE(created_at) created, 0 users, 0 posts, 0 updates, 0 comments, COUNT(*) messages FROM messages GROUP BY created) as A WHERE created >= '2015-04-01' GROUP BY created ORDER BY `A`.`created` DESC")


# SELECT created, SUM(users), SUM(posts), SUM(updates), SUM(comments), SUM(messages)
#   FROM (
#       SELECT DATE(created_at) created, COUNT(*) users, 0 posts, 0 updates, 0 comments, 0 messages
#       FROM users GROUP BY created
#       UNION ALL
#       SELECT DATE(created_at) created, 0 users, COUNT(*) posts, 0 updates, 0 comments, 0 messages
#       FROM requests WHERE workflow_state != 'disabled' GROUP BY created
#       UNION ALL
#       SELECT DATE(created_at) created, 0 users, 0 posts, COUNT(*) updates, 0 comments, 0 messages
#       FROM requests WHERE workflow_state != 'disabled'  GROUP BY created
#       UNION ALL
#       SELECT DATE(created_at) created, 0 users, 0 posts, 0 updates, COUNT(*) comments, 0 messages
#       FROM comments GROUP BY created
#       UNION ALL
#       SELECT DATE(created_at) created, 0 users, 0 posts, 0 updates, 0 comments, COUNT(*) messages
#       FROM messages GROUP BY created
#   ) as A
# WHERE created >= '2015-04-01'
# GROUP BY created
# ORDER BY `A`.`created` DESC



  end

end
