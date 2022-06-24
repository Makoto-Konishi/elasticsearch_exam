module ArticleSearchable
  extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # index名を設定。誤った操作防止のため環境名を含めるようにする。
    index_name "es_article_#{Rails.env}"

    # 登録していくドキュメントのマッピング情報を定義。
    # ここでフィールドのタイプや、使用するアナライザーなどを指定できる。
    settings do
      mappings dynamic: 'false' do
        indexes :id, type: 'integer'
        indexes :user, type: 'text'
        indexes :title, type: 'text', analyzer: 'kuromoji'
        indexes :description, type: 'text', analyzer: 'kuromoji'
      end
    end

    # モデルの情報を登録するために、mappingで定義した情報に合わせてjsonに変換する。
    def as_indexed_json(*)
      attributes
        .symbolize_keys
        .slice(:id, :title, :description)
        .merge(user: user_name)
    end
  end

  def user_name
    user.name
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

    def es_search(query)
      __elasticsearch__.search({
                                 size: 10000,
                                 query: {
                                   multi_match: {
                                     fields: %w[id user title description],
                                     type: 'cross_fields',
                                     query: query,
                                     operator: 'and'
                                   }
                                 }
                               })
    end
  end
end
