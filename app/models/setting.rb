# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string(191)
#  value :string(191)
#

class Setting < ActiveRecord::Base
end
