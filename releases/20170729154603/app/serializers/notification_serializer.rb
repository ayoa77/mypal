class NotificationSerializer < BaseSerializer

  attributes :id,
             :notification_type,
             # :notable,
             :from_user_count,
             :description,
             :goto_path,
             :goto_type,
             :goto_id,
             :done,
             :updated_at
             
  has_one :from_user, serializer: UserNameAvatarSerializer

  def description
    result = nil
    begin
      if object.notable_type == "Request"
        result = object.notable.real_subject.truncate(80)
      elsif object.notable_type == "Comment"
        result = object.notable.content.truncate(80)
      end
    rescue => err
      CustomLogger.add(__FILE__, __method__, {notable: object.notable}, err)
    end
    result
  end

  def goto_path
    if object.notable_type == "Request"
      request_path(object.notable_id)
    elsif object.notable_type == "Comment"
      request_path(object.notable.request_id)
    elsif object.notable_type == "User"
      user_path(object.notable_id)
    else
      nil
    end
  end

  def goto_type
    if object.notable_type == "Request" || object.notable_type == "Comment"
      "Request"
    elsif object.notable_type == "User"
      "User"
    else
      nil
    end
  end

  def goto_id
    if object.notable_type == "Request"
      object.notable_id
    elsif object.notable_type == "Comment"
      object.notable.request_id
    elsif object.notable_type == "User"
      object.notable_id
    else
      nil
    end
  end

  def updated_at
    object.updated_at.to_i
  end

end