class UserMeSerializer < UserSerializer

  attributes :email,
             # :paypal,
             :email_setting,
             :unread_notifications_count,
             :unread_conversations_count,
             :socket_key,
             :tag_list

  def email
    if current_user.present? && current_user == object
      object.email
    else
      nil
    end
  end

  def unread_notifications_count
    Notification.where( user: object, read: false).count
  end

  def unread_conversations_count
    ConversationUser.where( user: object, unread: true).count
  end

  def socket_key
    if current_user.present? && current_user == object
      object.socket_key
    else
      nil
    end
  end


  # def paypal
  #   if current_user.present? && current_user == object
  #     object.paypal
  #   else
  #     nil
  #   end
  # end

  def email_setting
    if current_user.present? && current_user == object
      es = object.email_setting || EmailSetting.new
      { invitations: es.invitations, conversations: es.conversations, comments: es.comments, recomments: es.recomments, newfollowers: es.newfollowers, newsletters: es.newsletters }
    else
      nil
    end
  end

  def tag_list
    object.tags.order(:display_name).map(&:name)
  end

end