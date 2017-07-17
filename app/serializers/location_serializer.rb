class LocationSerializer < BaseSerializer

  attributes :id,
             :city,
             :region_code,
             :country_code,
             :display_text

end