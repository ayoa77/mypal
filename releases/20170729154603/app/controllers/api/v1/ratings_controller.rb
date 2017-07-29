class Api::V1::RatingsController < ApiUserController

  def index
    if signed_in?
      if params.has_key?(:rateable_type) && params.has_key?(:rateable_ids)
        ratings = Rating.where(user_id: current_user.id, rateable_type: params[:rateable_type]).where("rateable_id in (?)", params[:rateable_ids].split(','))
        render json: ratings, status: :ok
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

end