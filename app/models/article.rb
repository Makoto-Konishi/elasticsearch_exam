class Article < ApplicationRecord
  include Searchable

  belongs_to :publisher
  belongs_to :author
  belongs_to :category
end
