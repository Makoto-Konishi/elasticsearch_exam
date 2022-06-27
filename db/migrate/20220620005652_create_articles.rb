class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :description
      t.references :category
      t.references :author
      t.references :publisher
      t.timestamps
    end
  end
end
