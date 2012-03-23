require 'sinatra'
require 'sequel'
require 'json'
require 'http_service/crawl'
require 'http_service/cached_url'
require 'uri'

class HttpService < Sinatra::Application

  def log s
    puts "http-service: #{s}"
  end

  post '/crawls' do
    # request body is a list of urls as JSON array
    body = request.body.read
    urls = JSON.parse(body)['urls']
    c = Crawl.create(urls: urls.join("\n"))
    log "created crawl #{c.crawl_id}" 

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

  # This is mainly to get status and a list of urls for client to get bodies of
  # through sequential requests
  #
  # TODO make sure to include hypermedia links to show where to get results of
  # crawl per URL

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
        url_id = DB[:urls].first(url:x)[:url_id]
        { rel: "processed_url", href: url("/url/#{url_id}") } 
      }
    else
      status 200
    end
    representation.to_json
  end

  get '/url/:url_id' do |url_id|
    # TODO representation of body, content_type, any redirect
    # plus any failures
    DB["select urls.url, requests,header from urls inner join requests on (urls.last_request_id = requests.request_id) where url_id = ?", url_id].to_hash
  end

  get '/url/:url_id/body' do |url_id|
  end
end

