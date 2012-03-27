require 'http_service/database'

module HttpService
  class Request < Sequel::Model
    def recent?
      self.created > (Time.now - (60*10))
    end
  end

  module Database
    def self.create_request(res)
      unless DB[:urls].first(url: res[:url])
        DB[:urls].insert url: res[:url]
      end
      body = res.delete :body
      request_id = DB[:requests].insert res
      original_encoding = res[:content_type][/charset=(.*)/, 1] || 'UTF-8'
      puts "Detected original encoding: #{original_encoding}"
      body.force_encoding(original_encoding)
      DB[:urls].filter(url: res[:url]).update(last_request_id: request_id, last_body: body.encode('UTF-8', undef: :replace, invalid: :replace))
    rescue
      puts $!
      puts $!.backtrace
    end

    def self.recently_fetched?(url)
      last = DB[:requests].filter(url: url).order(:created.desc).first
      last && last[:created] > (Time.now - (60 * 10))
    end
  end
end
