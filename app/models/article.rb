class Article < ApplicationRecord
  include ArticleSearchable

  belongs_to :user
end
