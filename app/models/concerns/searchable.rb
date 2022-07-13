module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name "elasticsearch_#{Rails.env}"

    settings index: {
      analysis: {
        analyzer: {
          japanese_analyzer: {
            type: 'custom',
            char_filter: ['icu_normalizer'],
            tokenizer: 'kuromoji_tokenizer',
            filter: %w[kuromoji_baseform kuromoji_part_of_speech ja_stop kuromoji_number kuromoji_stemmer]
          }
        }
      }
    }

    mappings dynamic: 'false' do
      indexes :title, type: 'text', analyzer: 'japanese_analyzer'
      indexes :description, type: 'text', analyzer: 'japanese_analyzer'
      indexes :pdf, type: 'text', analyzer: 'japanese_analyzer'
      indexes :author do
        indexes :name, analyzer: 'japanese_analyzer'
      end
      indexes :category do
        indexes :name, analyzer: 'japanese_analyzer'
      end
      indexes :publisher do
        indexes :name, analyzer: 'japanese_analyzer'
      end
    end

    def as_indexed_json(*)
      attributes
        .delete_if { |key, value| key =~ /[a-z]+_id/ || key == 'created_at' || key == 'updated_at' || key == 'id' }
        .symbolize_keys
        .merge(pdf: image_url, publisher: { name: publisher.name }, author: { name: author.name }, category: { name: category.name })
    end

    def image_url
      if pdf.attached?
        io = ActiveStorage::Blob.service.send(:path_for, pdf.key)
        reader = PDF::Reader.new(io)
        texts = ''

        reader.pages.each do |page|
          texts = page.text.gsub(/[\r\n]/, '')
        end
        texts
      else
        nil
      end
    end

    after_commit ->(record) { ElasticsearchWorker.perform_async('index', record.id) }, on: :create
    after_commit ->(record) { ElasticsearchWorker.perform_async('index', record.id) }, on: :update
    after_commit ->(record) { ElasticsearchWorker.perform_async('delete', record.id) }, on: :destroy
  end

  class_methods do
    def search(query)

      __elasticsearch__.search({
                                 query: {
                                   multi_match: {
                                     fields: %w[publisher.name author.name category.name title description, pdf],
                                     type: 'cross_fields',
                                     query: query,
                                     operator: 'and'
                                   }
                                 }
                               })
    end
  end
end
