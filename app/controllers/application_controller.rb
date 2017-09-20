class ApplicationController < BaseController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_filter :check_browser, except: [:browser_not_supported]
  before_filter :ie9_root_redirect, except: [:index, :browser_not_supported]
  before_filter :set_settings
  before_filter :set_defaults, except: [:browser_not_supported]

  layout 'application'

  def index
  end

  def discover
    render "index"
  end

  def unsubscribe
  end

  def browser_not_supported
    if supported_browser?
      redirect_to root_path
    else
      render :layout => false
    end
  end


  private

  def check_browser
    redirect_to browser_not_supported_path if !supported_browser?
  end

  def ie9_root_redirect
    redirect_to root_path if browser.ie? && browser.version.to_i < 10
  end

  def supported_browser?
    return !(browser.ie? && browser.version.to_i < 9)
  end

  def set_settings
    @settings = {}
    Setting.all.each do |s|
      @settings[s.key] = s.value
    end
    @settings["WEBSOCKET_PREFIX"] = @websocket_prefix
    @settings["FAVICON"] = view_context.favicon_image_url
    @settings["SITE_NAME"] = @settings["CHINA"] == "1" ? "小圈" : "Skillster"
  end

  def set_defaults
    @locale_primary = @settings["LOCALE_PRIMARY"].to_sym rescue I18n.default_locale
    @locale_secondary = @settings["LOCALE_SECONDARY"].to_sym rescue nil

    #set locale
    begin
      if params.include?(:ln) && params[:ln].present? && I18n.available_locales.include?(params[:ln].to_sym) && (@locale_primary == params[:ln].to_sym || @locale_secondary == params[:ln].to_sym )
        I18n.locale = params[:ln].to_sym
        current_user.update_attributes(language: params[:ln]) if signed_in? && current_user.language != params[:ln]
      else
        detect_locale = @locale_primary
        if request.env['HTTP_ACCEPT_LANGUAGE'].present?
          request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}-[A-Z]{2}/).each do |l|
            detect_locale = l if I18n.available_locales.include?(l.to_sym) && (@locale_primary == l.to_sym || @locale_secondary == l.to_sym )
          end
          request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).each do |l|
            detect_locale = l if I18n.available_locales.include?(l.to_sym) && (@locale_primary == l.to_sym || @locale_secondary == l.to_sym )
          end
        end
        redirect_to url_for(params.merge(ln: detect_locale))
      end
    rescue
      redirect_to root_url(ln: @locale_primary)
    end

    @title = nil
    @description = view_context.localize_setting "DESCRIPTION"
    @icon = nil
  end

end
