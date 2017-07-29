class ApiController < BaseController
  
  include ActionController::Serialization # fix for using active-model-serializer in production environment
  
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  helper_method :current_user, :signed_in?
  serialization_scope :view_context

  # before_filter :slow_down_api_request

  protected

  # def verified_request?
  #   super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  # end

  def slow_down_api_request
    sleep 1.0
  end

end