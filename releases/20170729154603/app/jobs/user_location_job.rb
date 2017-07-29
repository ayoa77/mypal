require 'gun_mailer'

class UserLocationJob
  @queue = :location

  def self.perform(user_id, database)
    default_config ||= ActiveRecord::Base.connection.instance_variable_get("@config").dup
    ActiveRecord::Base.establish_connection(default_config.dup.update(:database => database))
    user = User.find_by!(id: user_id)
    geo_json = JSON.parse(Net::HTTP.get(URI.parse("http://freegeoip.net/json/#{user.ip}")))
    city = geo_json["city"]
    region = geo_json["region_name"]
    country = geo_json["country_name"]
    region_code = geo_json["region_code"]
    country_code = geo_json["country_code"]
    lat = geo_json["latitude"]
    lng = geo_json["longitude"]
    if country.present? && lat != 0 && lng != 0
      location = Location.find_by(city: city, region: region, country: country) || Location.create(city: city, region: region, country: country, region_code: region_code, country_code: country_code, lat: lat, lng: lng)
      if location.more_accurate_than(user.location)
        user.location = location
        user.save
        user.requests.update_all(location_id: location.id)
        user.populate_keywords
      end
    end
  end
end