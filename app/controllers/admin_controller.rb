class AdminController < BaseController

  before_filter :is_super_admin?
  before_filter :set_defaults

  layout 'admin'

  private

  def is_super_admin?
    redirect_to root_path unless signed_in? && current_user.super_admin?
  end

  def set_defaults

    @settings = {}
    Setting.all.each do |s|
      @settings[s.key] = s.value
    end
    @settings["SITE_NAME"] = @settings["CHINA"] == "1" ? "小圈" : "skillster"
  end

end
