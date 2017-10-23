class Admin::SettingsController < AdminController

  def index
    settings =  Setting.all
    @sings = settings.select { |sets| !sets.key.include?('STYLES') }
    @styles = settings.select { |sets| sets.key.include?('STYLES') }

  end

  def update
    @s = Setting.find_by!(id: params[:id])

    @s.update_attributes(setting_params)
    flash[:notice] = "Setting #{@s.key} has been updated"

    redirect_to admin_settings_path
  end

  private

  def setting_params
    params.require(:setting).permit(:value)
  end

end