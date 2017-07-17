class UserSerializer < BaseSerializer

  attributes :id,
             :name,
             :avatar_url,
             :biography,
             :website,
             :linkedin_url,
             :linkedin_name,
             :facebook_url,
             :facebook_name,
             :follower_count,
             :following_count,
             :request_count,
             :point_count,
             :admin,
             :enabled,
             :online,
             :last_seen_at,
             :followers,
             :tags

  def avatar_url
    if object.avatar_stored?
      Dragonfly.app.fetch(object.avatar_uid).url
    else
      nil
    end
  end

  def last_seen_at
    object.last_seen_at.to_i
  end

  def followers
    result = []
    object.followers.each do |u|
      result << UserNameAvatarSerializer.new(u).serializable_hash
      break if result.length >= 3
    end
    return result
  end

  def tags
    result = []
    object.tags.order(:display_name).each do |t|
      result << TagListSerializer.new(t).serializable_hash
    end
    return result
  end

end