class Admin::UsersController < AdminController

  def index
    @users = User.order(id: :desc)
  end

  def show
    @user = User.find(params[:id])
    @tags = ActsAsTaggableOn::Tag.order(:display_name)
  end

  def update
    user = User.find_by(id: params[:id])
    if user
      if params[:enabled]
        if user.update_attributes(enabled: params[:enabled])
          flash[:notice] = user.enabled? ? "User successfully enabled." : "User successfully disabled."
        else
          flash[:alert] = "Unable to update user!"
        end
      elsif params[:admin]
        if user.update_attributes(admin: params[:admin])
          flash[:notice] = user.admin? ? "Admin rights given to user." : "Admin rights removed from user."
        else
          flash[:alert] = "Unable to update user!"
        end
      end
    else
      flash[:alert] = "User not found!"
    end
    redirect_to admin_user_path(user)
  end

  # def destroy
  #   user = User.find_by(id: params[:id])
  #   if user
  #     #disable the user
  #     user.enabled = false;
  #     user.active_sessions = []
  #     user.save
  #     #disable the requests
  #     user.requests.active.each do |r|
  #       r.disable!
  #     end
  #     #disable all comments
  #     user.comments.update_all(enabled: false)
  #     #remove all ratings
  #     #remove all request involvement (except own ones)
  #   end
  # end

end