class Article < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Searchable

  belongs_to :publisher
  belongs_to :author
  belongs_to :category
  has_one_attached :pdf

  # def search_data
  #   {
  #     title: title,
  #     description: self&.description,
  #     publisher_name: publisher.name,
  #     category_name: category.name,
  #     author_name: author.name,
  #     pdf: image_url
  #   }
  # end

  # def image_url
  #   if pdf.attached?
  #     io = ActiveStorage::Blob.service.send(:path_for, pdf.key)
  #     reader = PDF::Reader.new(io)
  #     texts = ''
  #
  #     reader.pages.each do |page|
  #       texts = page.text.gsub(/[\r\n]/, '')
  #     end
  #     texts
  #   else
  #     nil
  #   end
  # end
end
