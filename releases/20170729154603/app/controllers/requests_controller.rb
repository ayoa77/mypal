class RequestsController < ApplicationController

  def show
    @request = Request.find_by!(id: params[:id])
    if @request.disabled?
      raise ActiveRecord::RecordNotFound
    end
    @title = @request.real_subject
    @description = t "user.by", name: @request.user.name, bio: @request.user.biography
    @icon = @request.user.avatar.thumb('256x256').url
    render "application/index"
  end

end