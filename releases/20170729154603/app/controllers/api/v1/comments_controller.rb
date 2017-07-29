class Api::V1::CommentsController < ApiUserController

  # def index
  #   request = Request.find_by!(id: params[:request_id])
  #   if !request.disabled?
  #     render json: request.comments.where(enabled: true).order(id: :asc).includes(:user)
  #   else
  #     render json: nil, status: :not_found
  #   end
  # end

  def create
    if signed_in?
      request = Request.find_by!(id: params[:request_id])
      if !request.disabled?
        comment = Comment.new(user: current_user, request: request)
        if comment.update_attributes(comment_params)
          # request.update_columns(comment_count: request.comments.where(enabled:true).count)
          request.users << current_user unless request.users.include?(current_user) # add current user to request users (needed for adding a request to this user's dashboard)
          request.update_score(:comment)
          if request.user != comment.user
            GunMailer.send_new_comment_my_request(request.user, comment)
          end
          request.comment_users.each do |u|
            if u != request.user && u != comment.user
              GunMailer.send_new_comment_commented_request(u, comment) 
            end
          end
          render json: comment, status: :created
        else
          render json: {errors: comment.errors}, status: :unprocessable_entity
        end
      else
        render json: nil, status: :not_found
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  def destroy
    comment = Comment.find_by!(id: params[:id])
    if signed_in? && (comment.user == current_user || current_user.admin?) && comment.enabled?
      comment.update_columns(enabled: false)
      comment.request.update_score(:comment)
      # request.update_columns(comment_count: request.comments.where(enabled:true).count)
      render json: comment
    else
      render json: nil, status: :unauthorized
    end
  end

  def rate
    comment = Comment.find_by!(id: params[:id])
    if signed_in?
      rating = comment.rate current_user, params[:rating]
      if rating.errors.present?
        render json: {errors: rating.errors}, status: :unprocessable_entity
      else
        render json: comment, status: :ok
      end
    else
      render json: nil, status: :unauthorized
    end
  end

  # def rate
  #   comment = comment.find_by!(id: params[:id])
  #   if signed_in?
  #     rating = comment.rate current_user, params[:rating]
  #     if rating.errors.present?
  #       render json: {errors: rating.errors}, status: :unprocessable_entity
  #     else
  #       render json: nil, status: :ok
  #     end
  #   else
  #     render json: nil, status: :unauthorized
  #   end
  # end

  private

  def comment_params
    params.require(:comment).permit(
      :content
    )
  end

end