class Article < ApplicationRecord
  validates :link, uniqueness: true

  WEBDOMAIN = ['https://www.diamonds.net/News/', 'http://www.idexonline.com/', 'https://www.thediamondloupe.com/']
end
