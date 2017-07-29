class UserNameAvatarSerializer < BaseSerializer

  attributes :id,
             :name,
             :avatar_url
             
  def avatar_url
    if object.avatar_stored?
      Dragonfly.app.fetch(object.avatar_uid).url
    else
      nil
    end
  end

end