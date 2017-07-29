class ProxyController < ActionController::Base

  def img
    begin
      url = URI.parse(params["url"])
      result = Net::HTTP.get_response(url)
      send_data result.body, :type => result.content_type, :disposition => 'inline'
    rescue => err
      send_file Rails.public_path.join("no-image-available.png"), type: 'image/png', disposition: 'inline'
    end
  end

end