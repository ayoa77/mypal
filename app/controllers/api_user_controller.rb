class ApiUserController < ApiController
  
  before_filter :is_logged_in?

  protected

  def is_logged_in?
    unless signed_in?
      render json: nil, status: :unauthorized
    end
  end

end