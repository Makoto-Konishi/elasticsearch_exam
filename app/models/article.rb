class Article < ApplicationRecord
  include Rails.application.routes.url_helpers
  require 'open-uri'
  searchkick language: 'japanese'

  belongs_to :publisher
  belongs_to :author
  belongs_to :category
  has_one_attached :pdf

  def search_data
    {
      title: title,
      description: self&.description,
      publisher_name: publisher.name,
      category_name: category.name,
      author_name: author.name,
      pdf: image_url
    }
  end

  def image_url
    if pdf.attached?
      io = ActiveStorage::Blob.service.send(:path_for, pdf.key)
      extract_texts_from_pdf(io)
    else
      nil
    end
  end

  def extract_texts_from_pdf(io)
    reader = PDF::Reader.new(io)
    texts = ''

    reader.pages.each do |page|
      texts = page.text.gsub(/[\r\n]/, '')
    end
    texts
  end
end
