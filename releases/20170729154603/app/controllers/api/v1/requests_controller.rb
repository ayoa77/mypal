require 'gun_mailer'
class Api::V1::RequestsController < ApiUserController

  skip_before_filter :is_logged_in?, :only => [:show, :index]

  def index
    requests = Request.all

    if params.has_key?(:user_id) # show requests of a user
      user = User.find_by!(id: params[:user_id])
      if params.has_key?(:filter) && params[:filter] == "mine"
        requests = requests.where(user: user)
      else
        requests = user.involved_requests
      end

    elsif params.has_key?(:tag) # show requests of a tag
      tag = ActsAsTaggableOn::Tag.find_by!(name: params[:tag])
      requests = Request.tagged_with(tag.name)
      if tag.request_id.present? # filter the sticky request
        requests = requests.where.not(id: tag.request_id)
      end
    else # show requests for news feed / discover feed
      following_tag_ids = []
      following_user_ids = []
      all_tag_ids = ActsAsTaggableOn::Tag.all.map(&:id)
      if signed_in? 
        following_tag_ids = current_user.tags.map(&:id)
        following_user_ids = [current_user.id] + current_user.following.map(&:id)
      else 
        following_tag_ids = ActsAsTaggableOn::Tag.all.map(&:id)
      end

      requests = requests.joins("LEFT JOIN `taggings` ON `taggings`.`taggable_id` = `requests`.`id` AND `taggings`.`taggable_type` = 'Request'")
      if params.has_key?(:discover) # discover feed
        not_following_tag_ids = ActsAsTaggableOn::Tag.all.map(&:id) - following_tag_ids
        if following_user_ids.present?
          requests = requests.where('`taggings`.`tag_id` IN (?) OR (`taggings`.`tag_id` IS NULL AND `requests`.`user_id` NOT IN (?))', not_following_tag_ids, following_user_ids).distinct
        else
          requests = requests.where('`taggings`.`tag_id` IN (?) OR `taggings`.`tag_id` IS NULL', not_following_tag_ids).distinct
        end
      else
        requests = requests.where('`taggings`.`tag_id` IN (?) OR `requests`.`user_id` IN (?)', following_tag_ids, following_user_ids).distinct
      end
    end

    # hide inactive requests
    requests = requests.active

    # set the ordering
    requests = requests.order(created_at: :desc)

    # # old ordering options
    # if params.has_key?(:order) && params[:order] == "new"
    #   requests = requests.order(created_at: :desc)
    # elsif params.has_key?(:order) && params[:order] == "top"
    #   requests = requests.top_last_week
    # else
    #   # requests = requests.order("(`requests`.`like_count` - TIME_TO_SEC(TIMEDIFF(NOW(), `requests`.`created_at`))/(3600*12)) DESC")
    #   requests = requests.order("(  POW(0.6, TIME_TO_SEC(TIMEDIFF(NOW(), `requests`.`created_at`))/(3600*24)) * `requests`.`score`) DESC")
    # end
    page = params[:page] || 1
    requests = requests.paginate(:page => page, :per_page => 3).includes(:tags, :likers, :users, user: [:location], comments: [:user])
    requests.each do |request|
      if signed_in?
        viewing = Viewing.find_by(viewable: request, user: current_user) || Viewing.create(viewable: request, user: current_user)
        Viewing.increment_counter(:view_count, viewing.id)
        request.update_score(:view)
      end
    end
    render json: requests, status: :ok
  end

  def show
    if signed_in? || Setting.find_by(key: "PRIVATE").value != "1"
      request = Request.find_by!(id: params[:id])
      if !request.disabled? 
        if signed_in?
          viewing = Viewing.find_by(viewable: request, user: current_user) || Viewing.create(viewable: request, user: current_user)
          Viewing.increment_counter(:view_count, viewing.id)
          request.update_score(:view)
        end
        render json: request, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def create
    if signed_in?
      request = Request.new(user: current_user)
      if request.update_attributes(request_params)
        if params[:request].has_key?(:tag)
          tag = ActsAsTaggableOn::Tag.find_by(name: params[:request][:tag])
          if tag.present?
            request.tag_list.add(tag.name)
            request.save
          end
        end

        current_user.involved_requests << request
        # current_user.tag_list.add(request.tag_list)
        current_user.request_count = current_user.requests.active.count
        current_user.save
        # request.tag_list.each do |t|
        #   ActsAsTaggableOn::Tag.find_by(name: t).populate
        # end
        render json: request, status: :created
      else
        render json: {errors: request.errors}, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def destroy
    request = Request.find_by!(id: params[:id])
    if signed_in? && (request.user == current_user || current_user.admin?)
      if request.can_disable?
        request.disable!
        ActsAsTaggableOn::Tag.where(request: request).update_all(request_id: nil)
        current_user.request_count = current_user.requests.active.count
        current_user.save
      end
      render json: request
    else
      render json: nil, status: :unauthorized
    end
  end

  def rate
    request = Request.find_by!(id: params[:id])
    if signed_in?
      rating = request.rate current_user, params[:rating]
      if rating.errors.present?
        render json: {errors: rating.errors}, status: :unprocessable_entity
      else
        render json: request, status: :ok
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  private

  def request_params
    params.require(:request).permit(
      :subject,
      :content, 
      :reward
    )
  end


end