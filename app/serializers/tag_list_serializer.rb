class TagListSerializer < BaseSerializer

  attributes :id,
             :name,
             :display_name,
             :icon,
             :user_count,
             :banner_url,
             :small_url
             
end
