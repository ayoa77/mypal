class RemovePrivateFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :private
  end
end
