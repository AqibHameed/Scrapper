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
        Article.create(name: title, link: link,posted_date: date)
      end
    end

  end

  def idexonline
    idexonline_url = 'http://www.idexonline.com/newsroom'
    idexonline_html = open(idexonline_url)
    idexonline_doc = Nokogiri::HTML(idexonline_html)

    idexonline_rows = idexonline_doc.at('div.short-articles').xpath('./div')

    idexonline_rows.each do |row|
      title = row.search('div.title').text
      link = Article::WEBDOMAIN.second+row.search('p.article-text').xpath('./a').first['href']
      date_text = row.search('div.title').search('span.date').text
      date = DateTime.parse(date_text)

      if 7.days.ago < date.to_date  && date  <= Date.today
        Article.create(name: title, link: link, posted_date: date)
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
        if (7.days.ago < date.to_date  && date  <= Date.today)
          Article.create(name: title, link: link, posted_date: date)
        end
      end
    end
  end


  task :scrap_news_data => :environment do
    begin
       diamonds
    rescue
      puts "eerror in diamonds task"
    end

    begin
      idexonline
    rescue
      puts "error in idexonline task"
    end

    begin
      thediamondloupe
    rescue
      puts "error in thediamondloupe task"
    end
  end

end