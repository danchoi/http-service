require 'http_service'

module HttpService
  class CachedUrl
    def self.find(url_id)
      x = DB["select urls.url, response_code, redirect, content_type, headers, created, error, length(urls.last_body) as body_length
        from urls inner join requests on (urls.last_request_id = requests.request_id) 
        where url_id = ?", url_id].first
      x ? x.to_hash : nil 
    end

    def self.find_body(url_id)
      DB["select last_body from urls where urls.url_id = ?", url_id].first[:last_body]
    end
  end
end

if __FILE__ == $0
  require 'yaml'
  r = HttpService::CachedUrl.find ARGV.first.to_i
  puts r.to_yaml
end
