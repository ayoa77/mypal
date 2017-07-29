class TagSerializer < TagListSerializer

  # has_one :user, serializer: UserNameAvatarSerializer
  has_one :request 

end