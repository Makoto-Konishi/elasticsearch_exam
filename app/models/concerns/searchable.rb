module Searchable
  extend ActiveSupport::Concern
  included do # ブロックに定義した処理を include する側のクラスのコンテキストで実行する
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # index名を設定。誤った操作防止のため環境名を含めるようにする。
    index_name "elasticsearch_article_#{Rails.env}"

    # 登録していくドキュメントのマッピング情報を定義。
    # ここでフィールドのタイプや、使用するアナライザーなどを指定できる。
    settings do
      mappings dynamic: 'false' do
        indexes :publisher, type: 'text', analyzer: 'kuromoji'
        indexes :author, type: 'text', analyzer: 'kuromoji'
        indexes :category, type: 'text', analyzer: 'kuromoji'
        indexes :title, type: 'text', analyzer: 'kuromoji'
        indexes :description, type: 'text', analyzer: 'kuromoji'
      end
    end
    # モデルの情報を登録するために、mappingで定義した情報に合わせてjsonに変換する。
    def as_indexed_json(options = {})
      attributes
        .symbolize_keys
        .slice(:title, :description)
        .merge(publisher: publisher.name, author: author.name, category: category.name)
    end
  end

  class_methods do
    # indexを作成するメソッド。作成済みの場合は再作成するように一度削除処理を入れている.
    def create_index!
      client = __elasticsearch__.client
      client.indices.delete index: self.index_name rescue nil
      client.indices.create(index: self.index_name,
                            body: {
                              settings: self.settings.to_hash,
                              mappings: self.mappings.to_hash
                            })
    end

  end
end
