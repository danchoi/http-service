# encoding: UTF-8

require 'curb'
require 'request'

class Crawl < Sequel::Model
  SLICE = 10

  def before_create
    self.started = Time.now
    self.url_count = urls.split(/\n/).size
  end

  def log s
    puts "crawl #{self.crawl_id} -> #{s}"
  end

  def parallel_fetch
    start = Time.now
    cumulative_times = []
    m = Curl::Multi.new
    urls.split(/\n/).each_slice(SLICE).with_index do |slice, i|
      slice.each do |url| 
        last_request =  Request.filter(url:url).order(:request_id.desc).first
        if last_request && last_request.recent?
          log "using cached #{url}"
          self.used_cached_count += 1
          save
          next
        end
        start_time = Time.now
        res = {:body => "", :headers => "", url: url, crawl_id:self.crawl_id}
        c = Curl::Easy.new(url) do |curl|
          curl.follow_location = true
          curl.useragent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092416 Firefox/3.0.3"
          curl.on_body {|data| res[:body] << data; data.size}
          curl.on_header {|data| res[:headers] << data; data.size}
          curl.timeout = 90  # how can we handle an error?
          curl.on_complete do |easy| 
            next if easy.response_code == 0
            log "completed #{url}"
            self.success_count += 1
            save
            res[:latency] = Time.now - start_time
            cumulative_times << res[:latency]
            res[:response_code] = easy.response_code.to_s
            res[:content_type] = easy.content_type  # e.g. text/xml; charset=UTF-8
            if url != easy.last_effective_url
              res[:redirect] = easy.last_effective_url
            end
            Database.create_request(res)
          end
          curl.on_failure do |easy,code|
            log "failed #{url}"
            res[:error] = code.to_s       # e.g.  [Curl::Err::HostResolutionError, "Couldn't resolve host name"]
            Database.create_request(res)
          end
        end
        m.add c
      end
      m.perform
      self.completed = Time.now 
      save
    end
    log "Done"
    @results
  end
end

if __FILE__ == $0
  require 'yaml'

  feeds = %w(
   http://fulltextrssfeed.com/gonedigital.net/feed
   http://fulltextrssfeed.com/www.telegraph.co.uk/news/rss
   http://fulltextrssfeed.com/www.basingstokegazette.co.uk/news/rss
   http://fulltextrssfeed.com/www.thesquareball.net/feed
   http://fulltextrssfeed.com/www.badscience.net/feed
   http://fulltextrssfeed.com/www.economist.com/feeds/print-sections/76/britain.xml
   http://fulltextrssfeed.com/www.basingstokegazette.co.uk/business/rss
   http://nosoftskills.com/feed
   http://feedsanitizer.appspot.com/sanitize?url=http%3A%2F%2Fsimu.rtwblog.de%2Ffeed%2F&format=rss
   http://fulltextrssfeed.com/blog.independent.org/feed
   http://kindlefeeder.com/fail
   http://kindlefeeders.com/fail
  )

  b = Crawl.create(urls: feeds.join("\n"))
  b.parallel_fetch 

end
