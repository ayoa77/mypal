class Api::V1::NotificationsController < ApiUserController

  def index
    if signed_in?
      notifications = current_user.notifications.order(updated_at: :desc)
      page = params[:page] || 1
      notifications = notifications.paginate(:page => page, :per_page => 10).includes(:from_user,:notable)
      if page.to_i == 1
        current_user.notifications.update_all(read: true)
        Fiber.new do
          WebsocketRails["#{@websocket_prefix}_user_#{current_user.id}"].trigger(:notification_read_update, { count: Notification.where(user: current_user, read: false).count })
        end.resume
      end
      render json: notifications, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def done
    notification = Notification.find_by!(id: params[:id])
    if signed_in? && notification.user == current_user
      notification.update_columns(done: true)
      render json: nil, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

end
