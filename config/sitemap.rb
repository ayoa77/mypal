# Set the host name for URL creation

default_config = ActiveRecord::Base.connection.instance_variable_get("@config").dup
ActiveRecord::Base.connection.execute('SHOW databases').each do |db|
  if db[0].starts_with?("blnkk")
    ActiveRecord::Base.establish_connection(default_config.dup.update(:database => "#{db[0]}"))

    begin

      settings = {}
      Setting.all.each do |s|
        settings[s.key] = s.value
      end

      # SitemapGenerator::Sitemap.default_host = "http://mypal.co" rescue ""

      SitemapGenerator::Sitemap.default_host = settings["SITE_URL"] rescue "http://mypal.co"
      SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{settings["SUBSITE"].downcase.to_url}"

      SitemapGenerator::Sitemap.create do

        locales = []
        locales << settings["LOCALE_PRIMARY"] if settings["LOCALE_PRIMARY"].present?
        locales << settings["LOCALE_SECONDARY"] if settings["LOCALE_SECONDARY"].present?

        locales.each do |locale|
          add root_path(ln: locale), priority: 1.0, changefreq: 'always'
        end

        # locales.each do |locale|
        #   add tags_path(ln: locale), priority: 0.9
        #   add users_path(ln: locale), priority: 0.9
        # end

        # locales.each do |locale|
        #   ActsAsTaggableOn::Tag.order(:position).each do |t|
        #     add tag_path(t.name, ln: locale), priority: 0.9, changefreq: 'always'
        #   end
        # end

        if settings["PRIVATE"] != "1"
          Request.active.order(raw_score: :desc).each do |r|
            locales.each do |locale|
              add request_path(r, ln: locale), priority: 0.7, lastmod: r.updated_at
            end
          end
        end

        # User.where(enabled: true).order(id: :desc).each do |u|
        #   locales.each do |locale|
        #     add user_path(u, ln: locale), priority: 0.5, lastmod: u.updated_at
        #   end
        # end

        # I18n.available_locales.each do |locale|
        #   Page.all.each do |p|
        #     add page_path(p.key, ln: locale), priority: 0.1, changefreq: 'yearly', lastmod: p.updated_at
        #   end
        # end
      end
    rescue
      puts "Couldn't create sitemap for #{db[0]}"
    end
  end
end
