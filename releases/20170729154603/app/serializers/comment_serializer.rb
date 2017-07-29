class CommentSerializer < BaseSerializer

  attributes :id,
             :content,
             :created_at,
             :like_count,
             :report_count
             
  has_one :user, serializer: UserNameAvatarSerializer

  def created_at
    object.created_at.to_i
  end

  def report_count
    if current_user.present? && current_user.admin?
      object.report_count
    else
      nil
    end
  end

end