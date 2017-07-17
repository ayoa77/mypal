class TagsController < ApplicationController

  def index
    # @tags = ActsAsTaggableOn::Tag.order(:display_name)
    # @title = t "tag.index_title"
    render "application/index"
  end

  def show
    # @tag = ActsAsTaggableOn::Tag.find_by!(name: params[:id])
    # @requests = Request.active.tagged_with(params[:id]).top_last_week
    # @title = @tag.display_name  
    render "application/index"
  end

end