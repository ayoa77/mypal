class Admin::ConversationsController < AdminController

  def index
    @conversations = Conversation.order(id: :desc).includes(conversation_users: [:user])
  end

end