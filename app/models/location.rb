# == Schema Information
#
# Table name: locations
#
#  id           :integer          not null, primary key
#  city         :string(191)
#  region       :string(191)
#  country      :string(191)
#  region_code  :string(191)
#  country_code :string(191)
#  lat          :float(24)
#  lng          :float(24)
#  created_at   :datetime
#  updated_at   :datetime

class Location < ActiveRecord::Base
 establish_connection(Rails.env.to_sym)

  has_many :users

  def display_text
    result = []
    result << self.city         if self.city.present?
    result << self.region_code  if !result.empty? && self.region_code.present? && self.country_code == 'US'
    result << self.region       if result.empty? && self.region.present?
    result << self.country_code if !result.empty? && self.country_code.present? && self.country_code != 'US'
    result << self.country       if result.empty? && self.country.present?
    return result.join(", ")
  end

  def more_accurate_than old_location
    return true if old_location.nil?
    return true if self.country != old_location.country
    return false if !self.city.present? && old_location.city.present?
    return false if !self.region.present? && old_location.region.present?
    return true
  end

end
