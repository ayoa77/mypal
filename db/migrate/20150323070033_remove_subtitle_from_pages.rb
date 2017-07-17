class RemoveSubtitleFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :subheader
  end
end
