class UsersController < ApplicationController

  def index
    render "application/index"
  end

  def show
    # @user = User.find_by!(id: params[:id])
    # if !@user.enabled?
    #   raise ActiveRecord::RecordNotFound
    # end
    # @title = @user.name
    # @description = @user.biography
    # @icon = @user.avatar.thumb('256x256').url
    render "application/index"
  end

  def notifications
    render "application/index"
  end

  def edit
    render "application/index"
  end

  def invite
    render "application/index"
  end
end