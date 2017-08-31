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
      @tag = ActsAsTaggableOn::Tag.new(tag_params)
      @tag.user = current_user
      @tag.display_name = tag_params[:name]
      @city_image = @tag.build_city_image(city_image_params)
      @tag.banner_url = @city_image.banner.url
      @tag.small_url = @city_image.small.url
      if @tag.save
        @tag.reload
        current_user.tag_list << @tag.name
        current_user.save
        @tag.populate
        flash[:notice] = "New city #{@tag.name} created"
        redirect_to admin_acts_as_taggable_on_tags_path
      else
        t.fourth.banner_url = t.fourth.city_image:banner, :small_url.url
        flash[:alert] = "Creating city failed"
        render :new
      end
    end

    def update
      @tag = ActsAsTaggableOn::Tag.find_by(id: params[:id])
      @city_image = @tag.city_image
      @tag.banner_url = @city_image.banner.url
      @tag.small_url = @city_image.small.url
      if @tag.update_attributes(tag_params) && @city_image.update_attributes(city_image_params)
        flash[:notice] = "city #{@tag.name} updated"
        redirect_to acts_as_taggable_on_tags_path
      else
        flash[:alert] = "Updating city failed"
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
