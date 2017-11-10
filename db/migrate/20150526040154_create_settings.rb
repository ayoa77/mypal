class CreateSettings < ActiveRecord::Migration
  def change
    unless table_exists?(:settings)
      create_table :settings do |t|
        t.string :key
        t.string :value
      end
    end
  end
end
