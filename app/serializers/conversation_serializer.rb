class ConversationSerializer < BaseSerializer

  attributes 	:id,
              :user,
              :messages

  def user
    object.users.each do |u|
      return UserCardSerializer.new(u).serializable_hash if u.id != current_user.id
    end
  end

  def messages
    result = []
    object.messages.includes(:user).last(100).each do |m|
      result << MessageSerializer.new(m).serializable_hash
    end
    return result
  end

end