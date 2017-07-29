require 'gun_mailer'
class Api::V1::ConversationsController < ApiUserController

  def index
    if signed_in?
      conversations = current_user.conversations
      conversations = conversations.includes(:conversation_users).where(conversation_users: { user: current_user }).select("conversations.*, conversation_users.unread")
      conversations = conversations.order(updated_at: :desc).includes(users: [:location])
      render json: conversations, status: :ok, each_serializer: ConversationListSerializer
    else
      render json: nil, status: :unauthorized
    end
  end

  def show
    if signed_in?
      conversation = Conversation.find_by(id: params[:id])
      if conversation.present? && conversation.users.include?(current_user)
        conversation.mark_read(current_user)
        Fiber.new do
          WebsocketRails["#{@websocket_prefix}_user_#{current_user.id}"].trigger(:conversation_read_update, { count: ConversationUser.where( user: current_user, unread: true).count })
        end.resume
        render json: conversation, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def rate
    conversation = Conversation.find_by(id: params[:id])
    if conversation.nil?
      render json: nil, status: :not_found
    else
      if signed_in?
        rating = conversation.rate current_user, params[:rating]
        if rating.errors.present?
          render json: {errors: rating.errors}, status: :unprocessable_entity
        else
          render json: nil, status: :ok
        end
      else
        render json: nil, status: :unauthorized
      end
    end
  end

end