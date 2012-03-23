require 'sinatra'
require 'sequel'
require 'json'
require 'crawl'

class HttpService < Sinatra::Application

  post '/crawls' do
    # request body is a list of urls as JSON array
    body = request.body.read
    urls = JSON.parse(body)['urls']
    c = Crawl.create(urls: urls.split(/\n/))
    puts c.inspect
    # CHANGME. Do this asynchronously in a separate process or crontask
    # c.parallel_fetch 
    c.to_json
  end

  # This is mainly to get status and a list of urls for client to get bodies of
  # through sequential requests
  #
  # TODO make sure to include hypermedia links to show where to get results of
  # crawl per URL

  get '/crawl/:id' do |id|
    DB[:crawls].first(crawl_id:id).to_json
  end

  get '/url' do 
    url = params[:url]
    # TODO representation of body, content_type, any redirect

  end
end

