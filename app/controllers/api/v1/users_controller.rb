class Api::V1::UsersController < ApiUserController

  def index
    group_query = nil
    blnkk_team_query = nil
    not_followed_by_query = nil
    followed_by_query = nil
    following_query = nil
    show_user_card = params.has_key?(:serializer) && params[:serializer] == "user_card"
    page = params[:page] || 1
    query = nil
    if params.has_key?(:q) # show all users which fit the search query
      query = params[:q]
      query.scan(/\bcategory:\S+\b/).each do |t|
        query.slice! t # remove this from the search string
        r = t.split(':')
        group_query = r[1] if r.size > 1
      end
      query.scan(/\bdoers-team\b/).each do |t|
        query.slice! t
        blnkk_team_query = true
      end
      query.scan(/\bwho-to-follow\b/).each do |t|
        query.slice! t
        if signed_in?
          not_followed_by_query = current_user
        end
      end
      query.scan(/\bnot-followed-by:\w+\b/).each do |t|
        query.slice! t # remove this from the search string
        r = t.split(':')
        not_followed_by_query = User.find_by(id: r[1]) if r.size > 1
      end
      query.scan(/\bfollowed-by:\w+\b/).each do |t|
        query.slice! t # remove this from the search string
        r = t.split(':')
        followed_by_query = User.find_by(id: r[1]) if r.size > 1
      end
      query.scan(/\bfollowing:\w+\b/).each do |t|
        query.slice! t # remove this from the search string
        r = t.split(':')
        following_query = User.find_by(id: r[1]) if r.size > 1
      end
      query = query.squish
    end
    if query.present?
      # response = User.search query: { multi_match: { fields: ["name", "linkedin_name", "facebook_name", "biography", "keywords"], query: query } }, size: 1000
      response = User.search(query.gsub(/\W/, ' '), index: ActiveRecord::Base.connection.current_database+"_users", size: 1000)
      users = response.records
    else
      users = User.all
    end

    if params.has_key?(:order) && params[:order] == "new"
      users = users.order(created_at: :desc)
    elsif params.has_key?(:order) && params[:order] == "last_seen"
      users = users.order(online: :desc, last_seen_at: :desc)
    elsif params.has_key?(:order) && params[:order] == "points"
      users = users.order(admin: :asc, point_count: :desc)
    # If there is a query, elesticsearch already sorts the results by score
    elsif !query.present?
      users = users.order(admin: :asc, point_count: :desc)
    end

    users = users.where(enabled: true)

    if group_query.present?
      users = users.tagged_with(group_query, on: :tags)
    end
    if blnkk_team_query.present?
      users = users.where(admin: true)
    end
    if followed_by_query.present?
      users = users.where("`id` IN (?)", followed_by_query.following.map(&:id))
    end
    if not_followed_by_query.present?
      users = users.where("`id` NOT IN (?)", [not_followed_by_query.id] + not_followed_by_query.following.map(&:id))
    end
    if following_query.present?
      users = users.where("`id` IN (?)", following_query.followers.map(&:id))
    end

    users = users.paginate(:page => page, :per_page => 5)

    if show_user_card
      render json: users, each_serializer: UserCardSerializer
    else
      if signed_in?
        users.each do |user|
          viewing = Viewing.find_by(viewable: user, user: current_user) || Viewing.create(viewable: user, user: current_user)
          Viewing.increment_counter(:view_count, viewing.id)
        end
      end
      render json: users.includes(:followers).to_a
    end

  end

  def show
    if params[:id] == 'me'
      if signed_in?
        render json: current_user, serializer: UserMeSerializer, root: :user
      else
        render json: nil, status: :not_found
      end
    else
      user = User.find_by(id:params[:id]);
      if user
        if signed_in?
          viewing = Viewing.find_by(viewable: user, user: current_user) || Viewing.create(viewable: user, user: current_user)
          Viewing.increment_counter(:view_count, viewing.id)
        end
        render json: user
      else
        render json: nil, status: :not_found
      end
    end
  end

  def update
    user = User.find_by!(id: params[:id])
    if signed_in? && user == current_user
      if params.has_key?(:user) && params[:user].has_key?(:avatar)
        params[:user][:avatar] = Base64.decode64(params[:user][:avatar])
      end
      if user.update_attributes(user_params)
        # if user.previous_changes.has_key?(:biography)
        #   user.requests.user_biography.update_all(workflow_state: :disabled)
        #   if user.biography.present?
        #     r = Request.create(user: user, content_type: :user_biography)
        #     user.involved_requests << r
        #   end
        # end
        render json: user, status: :ok, serializer: UserMeSerializer, root: :user
      else
        render json: {errors: user.errors}, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def rate
    user = User.find_by(id: params[:id])
    if user.nil?
      render json: nil, status: :not_found
    else
      if signed_in?
        rating = user.rate current_user, params[:rating]
        if rating.errors.present?
          render json: {errors: rating.errors}, status: :unprocessable_entity
        else
          render json: user, status: :ok
        end
      else
        render json: nil, status: :unauthorized
      end
    end
  end

  def addTag
    tag = ActsAsTaggableOn::Tag.find_by!(name: params[:tag]) # To make sure the tag exists
    if signed_in? && params.has_key?(:tag)
      current_user.tag_list.add(params[:tag])
      if current_user.save
        tag.populate
        render json: current_user, status: :ok, serializer: UserMeSerializer, root: :user
      else
        render json: current_user.errors, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def removeTag
    tag = ActsAsTaggableOn::Tag.find_by!(name: params[:tag]) # To make sure the tag exists
    if signed_in? && params.has_key?(:tag)
      current_user.tag_list.remove(params[:tag])
      if current_user.save
        tag.populate
        render json: current_user, status: :ok, serializer: UserMeSerializer, root: :user
      else
        render json: current_user.errors, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def invite
    if signed_in? && (Setting.find_by(key: "PRIVATE").value != "1" || current_user.admin?)
      if params[:receivers].present?
        params[:receivers].each do |receiver|
          name = receiver["name"]
          email = receiver["email"].downcase.strip
          source = receiver["source"]
          if source == "manual"
            email_array = email.split(',')
            email_array.each do |email|
              Invitation.invite(current_user, email)
              Contact.create(user:current_user, source: :manual, email: email)
            end
          else
            Invitation.invite(current_user, email, name)
          end
        end
        render json: nil
      else
        render json: nil, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def promote
    user = User.find_by!(id: params[:id])
    if signed_in? && current_user.admin? && user != current_user
      user.update_attributes(admin: true)
      render json: user, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def demote
    user = User.find_by!(id: params[:id])
    if signed_in? && current_user.admin? && user != current_user
      user.update_attributes(admin: false)
      render json: user, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def enable
    user = User.find_by!(id: params[:id])
    if signed_in? && current_user.admin? && user != current_user
      user.update_attributes(enabled: true)
      render json: user, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def disable
    user = User.find_by!(id: params[:id])
    if signed_in? && current_user.admin? && user != current_user
      user.update_attributes(enabled: false)
      render json: user, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  private

  def avatar_params
    params.permit(:avatar)
  end

  def user_params
    params.require(:user).permit(:name, :avatar, :biography, :website, email_setting_attributes: [:invitations, :conversations, :comments, :recomments, :newfollowers, :newsletters])
  end

end
