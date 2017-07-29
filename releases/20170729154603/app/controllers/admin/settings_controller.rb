class Admin::SettingsController < AdminController

  def index
    @sings = Setting.all.order(:id)
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