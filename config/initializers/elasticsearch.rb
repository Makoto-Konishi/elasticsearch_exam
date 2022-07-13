config = { host: ENV['ELASTICSEARCH_HOST'] || 'elasticsearch:9200/', port: '443' }
Elasticsearch::Model.client = Elasticsearch::Client.new(config)
