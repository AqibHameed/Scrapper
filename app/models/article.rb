class Article < ApplicationRecord
  self.inheritance_column = :_type_disabled
  validates :data, uniqueness: true
  validates :slug, uniqueness: true

  self.table_name = "submissions"
  belongs_to :category

  belongs_to :user
  WEBDOMAIN = ['https://www.diamonds.net/News/', 'http://www.idexonline.com/', 'https://www.thediamondloupe.com/']
end
