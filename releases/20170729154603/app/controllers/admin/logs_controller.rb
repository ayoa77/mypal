class Admin::LogsController < AdminController

  def index
    @logs = Log.all.order(id: :desc).limit(100)
  end

end