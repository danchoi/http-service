require 'sinatra'
require 'sequel'
require 'json'
require 'uri'
require 'http_service'
require 'redis'
REDIS = Redis.new

module HttpService
class API < Sinatra::Application

  def log s
    puts "http-service: #{s}"
  end

  post '/crawls' do
    # request body is a list of urls as JSON array
    body = request.body.read
    urls = JSON.parse(body)['urls']
    c = Crawl.create(urls: urls.join("\n"))
    log "created crawl #{c.crawl_id}; pushing onto queue" 
    REDIS.rpush "http-service:crawl-queue", c.crawl_id

    # CHANGME. Do this asynchronously in a separate process or crontask
    # c.parallel_fetch 
    
    status 202 # Accepted
    representation = {
      state: "pending",
      message: "Your request has been accepted",
      link: { rel: "self", href: url("/crawl/#{c.crawl_id}") }
    }
    representation.to_json
  end

  # This is mainly to get crawl status and links to the resource representation
  # for each URL crawl result. 

  get '/crawl/:id' do |id|
    crawl = Crawl[id]
    state = crawl.completed.nil? ? "pending" : "done"
    message = crawl.completed.nil? ? "Your request is still processing" : "Your request has been processed"
    representation = {
      state: state,
      message: message,
      link: { rel: "self", href: url("/crawl/#{crawl.crawl_id}") }
    }
    if crawl.completed
      status 202 # not 303; just include links in representation to save trips
      representation[:links] = crawl.urls_array.map {|x| 
        url_rec = DB[:urls].first(url:x)
        next unless url_rec
        url_id = url_rec[:url_id]
        { rel: "processed_url", href: url("/url/#{url_id}") } 
      }.compact
    else
      status 200
    end
    representation.to_json
  end

  get '/url/:url_id' do |url_id|
    u = CachedUrl.find url_id 
    if u
      representation = u.merge(
        link: { rel: "self", href: url("/url/#{url_id}") },
        links: { rel: "body", href: url("/url/#{url_id}/body") }
      )
      representation.to_json
    else
      status 404
    end
  end

  get '/url/:url_id/body' do |url_id|
    meta = CachedUrl.find(url_id)
    body = CachedUrl.find_body(url_id)
    # TODO: link header for self hypermedia link?
    headers "Content-Type" => meta[:content_type]
    body
  end
end
end
