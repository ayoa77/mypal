class Api::V1::TagsController < ApiUserController

  skip_before_filter :is_logged_in?, :only => [:index, :show]

  def index
    tags = ActsAsTaggableOn::Tag.all
    query = params[:q] || ''
    query.scan(/\bwhat-to-follow\b/).each do |t|
      query.slice! t
      if signed_in? && current_user.tag_list.present?
        tags = tags.where("`name` NOT IN (?)", current_user.tag_list)
      end
    end
    query.scan(/\bwhat-already-following\b/).each do |t|
      query.slice! t
      if signed_in?
        tags = tags.where("`name` IN (?)", current_user.tag_list)
      end
    end
    render json: tags.order(user_count: :desc) #.includes(:user)
  end

  def show
    # tag = ActsAsTaggableOn::Tag.find_by!(name: params[:id])
    # render :json => {:tag => tag, :city_image => city_image }}
    # render json: { tag: tag, city_image: city_image }
    # render json: {tag: {tag: tag, city_image: city_image }}
    tag = ActsAsTaggableOn::Tag.find_by!(name: params[:id])
    # tag = ActsAsTaggableOn::Tag.includes(:city_image).find_by!(name: params[:id])
    # city_image = tag.city_image
    # tag = tag.attributes.merge(:banner => city_image.banner.url, :small => city_image.small.url ).to_json
    render json: tag
  end

  def create
    if signed_in? && current_user.admin?
      tag = ActsAsTaggableOn::Tag.new(name: params[:name].to_url, display_name: params[:name], icon: params[:icon], user: current_user)
      if tag.save
        tag.reload
        current_user.tag_list << tag.name
        current_user.save
        tag.populate
        render json: tag, status: :created
      else
        render json: {errors: tag.errors}, status: :unprocessable_entity
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def update
    tag = ActsAsTaggableOn::Tag.find_by!(id: params[:id])
    if signed_in? && current_user.admin?
      if params.has_key?(:name)
        unless tag.update_attributes(name: params[:name].to_url, display_name: params[:name], icon: params[:icon])
          render json: {errors: tag.errors}, status: :unprocessable_entity
          return
        end
      end
      if params.has_key?(:request_id)
        request = params[:request_id].present? ? Request.find_by!(id: params[:request_id]) : nil
        unless tag.update_attributes(request_id: params[:request_id])
          render json: {errors: tag.errors}, status: :unprocessable_entity
          return
        end
      end
      render json: tag, status: :ok
    else
      render json: nil, status: :unauthorized
    end
  end

  def destroy
    tag = ActsAsTaggableOn::Tag.find_by!(id: params[:id])
    if signed_in? && current_user.admin?
      ActsAsTaggableOn::Tagging.where(tag_id: tag.id).delete_all
      tag.destroy
      render json: tag
    else
      render json: nil, status: :unauthorized
    end
  end

end
