class TagSerializer < TagListSerializer


  # has_one :user, serializer: UserNameAvatarSerializer
  has_one :request
  # has_one :city_image

end
