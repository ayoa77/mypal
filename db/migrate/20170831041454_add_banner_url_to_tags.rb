class AddBannerUrlToTags < ActiveRecord::Migration
  def change
    add_column :tags, :banner_url, :string
    add_column :tags, :small_url, :string

  end
end
