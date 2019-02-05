namespace :import_news do

  def diamonds
    diamond_url = 'https://www.diamonds.net/News/Articles.aspx'
    diamond_html = open(diamond_url)
    diamond_doc = Nokogiri::HTML(diamond_html)

    diamond_rows = diamond_doc.at('table#ctl00_ContentPlaceHolderMainContent_gvArticleList').xpath('./tr')

    diamond_rows.each do |row|
      title = row.search('a.ArticleTitle').text
      link = Article::WEBDOMAIN.first+row.search('a.ArticleTitle').first["href"]
      date_text = row.search('table.ArticleStats').search('td')[1].text.strip
      date = DateTime.parse(date_text)
      if 7.days.ago < date.to_date  && date <= Date.today
        data = '{"img": null, "url": "'+link+'", "type": "link", "embed": null, "title": "'+title+'", "domain": "'+URI.parse(link).host+'", "thumbnail": null, "description": null, "providerName": null, "publishedTime": null}'
        Article.create(slug: title.parameterize, title: title, type: "link", data: JSON.parse(data), category_name: "newsboat", user_id: @user.id, rate: 100, category_id: @category.id)
      end
    end

  end

  def idexonline
    idexonline_url = 'http://www.idexonline.com/newsroom'
    idexonline_html = open(idexonline_url)
    idexonline_doc = Nokogiri::HTML(idexonline_html)

    idexonline_rows = idexonline_doc.at('div.short-articles').xpath('./div')

    idexonline_rows.each do |row|
      title = row.search('div.title').search('h2').text
      title = row.search('div.title').search('h1').text if title.blank?
      link = Article::WEBDOMAIN.second+row.search('p.article-text').xpath('./a').first['href']
      date_text = row.search('div.title').search('span.date').text
      date = DateTime.parse(date_text)

      if 7.days.ago < date.to_date && date  <= Date.today
        data = '{"img": null, "url": "'+link+'", "type": "link", "embed": null, "title": "'+title+'", "domain": "'+URI.parse(link).host+'", "thumbnail": null, "description": null, "providerName": null, "publishedTime": null}'

        Article.create(slug: title.parameterize, title: title, type: "link", data: JSON.parse(data), category_name: "newsboat", user_id: @user.id, rate: 100, category_id: @category.id)
      end
    end
  end

  def thediamondloupe
    thediamondloupe_url = 'https://www.thediamondloupe.com'
    thediamondloupe_html = open(thediamondloupe_url)
    thediamondloupe_doc = Nokogiri::HTML(thediamondloupe_html)

    thediamondloupe_rows = thediamondloupe_doc.at('div.view-content').xpath('./div')

    thediamondloupe_rows.each do |row|
      title = row.search('div.field-name-title').text
      date_text = row.search('div.group-article-date').text

      link = Article::WEBDOMAIN.third+row.search('a.title').first['href']
      if date_text["YESTERDAY"]
        date = Date.today - 1
      else
        date = DateTime.parse(date_text) if date_text.present?
      end
      if date.present?
        data = '{"img": null, "url": "'+link+'", "type": "link", "embed": null, "title": "'+title+'", "domain": "'+URI.parse(link).host+'", "thumbnail": null, "description": null, "providerName": null, "publishedTime": null}'
        Article.create(slug: title.parameterize, title: title, type: "link", data: JSON.parse(data), category_name: "newsboat", user_id: @user.id, rate: 100, category_id: @category.id)
      end
    end
  end


  task :scrap_news_data => :environment do

    @user = User.find_by(username: "newsboat")
    if @user.blank?
      @user = User.create!(username: "newsboat", password: "password", color: "Dark", active: true,
                          settings: ' {"font": "Lato", "nsfw": false, "nsfw_media": false, "sidebar_color": "Gray", "notify_comments_replied": true, "notify_submissions_replied": true, "submission_small_thumbnail": true, "exclude_upvoted_submissions": false, "exclude_downvoted_submissions": true}')

    end
    @category = Category.find_by(name: "newsboat")

    @category = Category.create(name: "newsboat", discription: "Here you'll find latest news about diamonds.", nsfw: false ,color: "Dark", active: true)  if @category.blank?

    begin
      diamonds
    rescue => e
      puts e
    end

    begin
      idexonline
    rescue => e
      puts e
    end

    begin
      thediamondloupe
    rescue => e
      puts e
    end
  end

end