class BaseController < ActionController::Base

  before_filter :select_database

  protect_from_forgery with: :exception
  before_filter :validate_active_session
  
  protected

  def current_user
    if @_current_user.present?
      return @_current_user
    end
    @_current_user = session[:user_id] && User.find_by(id: session[:user_id])
    if @_current_user.present?
      @_current_user.log_activity request.ip
    end
    return @_current_user
  end

  def signed_in?
    !!current_user
  end

  def sign_in user_id, provider = nil
    sign_out
    session[:user_id] = user_id
    session[:provider] = provider
    current_user.activate_session session[:session_id]
  end

  def sign_out
    current_user.deactivate_session session[:session_id] if signed_in?
    session[:user_id] = nil
    @_current_user = nil
    reset_session
  end

  helper_method :current_user
  helper_method :signed_in?
  helper_method :sign_out

  def markdown_to_html(text)
    @_renderer ||= Redcarpet::Render::HTML.new({})
    @_markdown = Redcarpet::Markdown.new(@_renderer, extensions = {})
    @_markdown.render(text).html_safe
  end

  # to prevent 500 server errors for missing template errors
  rescue_from ActionView::MissingTemplate do |exception|
     raise ActionController::RoutingError.new(t "services.not_found")
  end

  private

  def select_database
    default_config ||= ActiveRecord::Base.connection.instance_variable_get("@config").dup
    begin
      if request.subdomain.empty?
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      else
        ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "blnkk_#{request.subdomain}"))
      end
      ActiveRecord::Base.connection.active? #raises expection if database does not exist
    rescue
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      redirect_to ENV['ROOT_URL']
    end
    @websocket_prefix = ActiveRecord::Base.connection.current_database
  end

  def validate_active_session
    if signed_in? && !(current_user.enabled? && current_user.active_sessions.include?(session[:session_id]))
      reset_session
      # redirect_to login_path
    end
  end

end