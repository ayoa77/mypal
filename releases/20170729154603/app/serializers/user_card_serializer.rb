class UserCardSerializer < BaseSerializer

  attributes :id,
             :name,
             :avatar_url,
             :online,
             :last_seen_at

  has_one :location

  def last_seen_at
    object.last_seen_at.to_i
  end

  def avatar_url
    if object.avatar_stored?
      Dragonfly.app.fetch(object.avatar_uid).url
    else
      nil
    end
  end

end