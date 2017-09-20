class Admin::ActsAsTaggableOnTagsController < AdminController


    def index
      @tags = ActsAsTaggableOn::Tag.all.order(:id)
    end

    def show
      @tag = ActsAsTaggableOn::Tag.find_by(id: params[:id])
    end

    def new
      @tag = ActsAsTaggableOn::Tag.new
      @city_image = @tag.build_city_image

    end

    def edit
      @tag = ActsAsTaggableOn::Tag.find_by(id: params[:id])
      @city_image = @tag.city_image
    end

    def create
      byebug
      @tag = ActsAsTaggableOn::Tag.new(tag_params)
      @tag.user = current_user
      @tag.display_name = tag_params[:name]
      @city_image = @tag.build_city_image(city_image_params)
      if @tag.save && @city_image.save
        @tag.banner_url = @city_image.banner.url
        # @tag.small_url = @city_image.small.url
        @tag.save
        @tag.reload
        current_user.tag_list << @tag.name
        current_user.save
        @tag.populate
        flash[:notice] = "New channel #{@tag.name} created"
        redirect_to admin_acts_as_taggable_on_tags_path
      else
        flash[:alert] = "Creating channel failed"
        render :new
      end
    end

    def update
      @tag = ActsAsTaggableOn::Tag.find_by(id: params[:id])
      @city_image = @tag.city_image
      if @tag.update_attributes(tag_params) || city_image_params.present? && @city_image.update_attributes(city_image_params.try)
        @tag.banner_url = @city_image.banner.url
        # @tag.small_url = @city_image.small.url
        @tag.display_name = tag_params[:name]
        @tag.save
        flash[:notice] = "channel #{@tag.name} updated"
        redirect_to admin_acts_as_taggable_on_tags_path
      else
        flash[:alert] = "Updating channel failed"
        render :edit
      end
    end

    def destroy
      @tag = ActsAsTaggableOn::Tag.find_by!(id: params[:id])
      @city_image = @tag.city_image
      if @tag.destroy && @city_image.destroy
        ActsAsTaggableOn::Tagging.where(tag_id: @tag.id).delete_all if ActsAsTaggableOn::Tagging.where(tag_id: @tag.id)
        flash[:notice] = "channel #{@tag.name} deleted"
        redirect_to admin_acts_as_taggable_on_tags_path
      else
        flash[:alert] = "Deleting channel failed"
        render :edit
      end
    end



    private

    def tag_params
      params.require(:acts_as_taggable_on_tag).permit(:position, :name, :display_name, :icon, :user_id, :request_id, :taggings_count, :user_count, :banner_url, :small_url)
    end

    def city_image_params
      params.require(:city_image).permit(:banner, :small) 
    end
end
