class ElasticsearchWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false

  Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil
  Client = Elasticsearch::Client.new host: 'elasticsearch:9200', logger: Logger

  def perform(operation, record_id)
    logger.debug [operation, "ID: #{record_id}"]

    case operation.to_s
    when /index/
      record = Article.find(record_id)
      Client.index index: 'elasticsearch_article_development', id: record.id, body: record.__elasticsearch__.as_indexed_json
    when /delete/
      begin
        Client.delete index: 'elasticsearch_article_development', id: record_id
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        logger.debug "Article not found, ID: #{record_id}"
      end
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
