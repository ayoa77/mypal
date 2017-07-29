class MessageSerializer < BaseSerializer

  attributes :id,
             :user_id,
             :content,
             :system_generated,
             :created_at

  has_one :user, serializer: UserNameAvatarSerializer

  def created_at
    object.created_at.to_i
  end
  
end