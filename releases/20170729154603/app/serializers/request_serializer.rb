include ActionView::Helpers::TextHelper
class RequestSerializer < BaseSerializer

  attributes :id,
             :subject,
             :content,
             :reward,
             :created_at,
             :user_reach_count,
             :like_count,
             :report_count,
             :comment_count,
             :tag,
             :likers,
             :repliers
             
  has_one :user, serializer: UserCardSerializer

  has_many :comments

  def subject
    object.real_subject
  end

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

  def tag
    TagListSerializer.new(object.tags.first).serializable_hash
  end

  def likers
    result = []
    object.likers.each do |u|
      result << UserNameAvatarSerializer.new(u).serializable_hash
    end
    return result
  end

  def repliers
    result = []
    object.users.each do |u|
      result << UserNameAvatarSerializer.new(u).serializable_hash if u != object.user
    end
    return result
  end

end