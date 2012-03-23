
require 'httparty'


# sample client library
require 'json'

class HttpService
  include HTTParty
  base_uri 'http://localhost:9292'
  format :json
end

urls = %w(
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

payload = {urls: urls}
puts HttpService.post('/crawls', body: payload.to_json)
  

