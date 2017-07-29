class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
# 20150209161054 for culprit
# 20150526040154
    end
  end
end
