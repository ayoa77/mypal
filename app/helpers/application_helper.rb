module ApplicationHelper
  def darken_color(hex_color, amount=0.4)
    begin
      hex_color = hex_color.gsub('#','')
      rgb = hex_color.scan(/../).map {|color| color.hex}
      rgb[0] = (rgb[0].to_i * amount).round
      rgb[1] = (rgb[1].to_i * amount).round
      rgb[2] = (rgb[2].to_i * amount).round
      return "#%02x%02x%02x" % rgb
    rescue
      return "#000000"
    end
  end

  # Amount should be a decimal between 0 and 1. Higher means lighter
  def lighten_color(hex_color, amount=0.6)
    begin
      hex_color = hex_color.gsub('#','')
      rgb = hex_color.scan(/../).map {|color| color.hex}
      rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
      rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
      rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
      return "#%02x%02x%02x" % rgb
    rescue
      return "#ffffff"
    end
  end
  # "#{@settings["SITE_URL"].chomp("/")}/logo.png"
  def logo_image_url
    "/logo.png"
  end
  # "#{@settings["SITE_URL"].chomp("/")}/favicon.png"
  def favicon_image_url
    "/favicon.ico"
  end
  # "#{@settings["SITE_URL"].chomp("/")}/share.png"
  def share_image_url
    "/logo.png"
  end

  def localize_setting setting
    if I18n.locale.to_s == @settings["LOCALE_SECONDARY"]
      return @settings[setting+"_SECONDARY"]
    else
      return @settings[setting+"_PRIMARY"]
    end
  end

end
