class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.text :name
      t.string :link
      t.datetime :posted_date

      t.timestamps
    end
  end
end
