class Admin::RequestsController < AdminController

  def index
    @requests = Request.order(created_at: :desc).includes(:user, :users, :tags)
    @tags = ActsAsTaggableOn::Tag.order(:display_name)
  end

  def update
    request = Request.find_by(id: params[:id])
    if request
      if params[:workflow_event] == "disable"
        request.disable!
      end
      if params[:workflow_event] == "enable"
        request.enable!
      end
      if params.has_key?(:request) && params[:request].has_key?(:tag)
        request.tag_list = [params[:request][:tag]]
        request.save
      end
      request.user.request_count = request.user.requests.active.count
      request.user.save
      flash[:notice] = "Request #{request.id} is now in state #{request.workflow_state}"
    else
      flash[:alert] = "Request not found!"
    end
    redirect_to admin_requests_path
  end

end