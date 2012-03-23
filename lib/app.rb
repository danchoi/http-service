require 'sinatra'
require 'sequel'
require 'json'
require 'crawl'

class HttpService < Sinatra::Application

  post '/crawls' do
    # request body is a list of urls as JSON array
    urls = JSON.parse(request.body.read)
    puts urls.inspect
    c = Crawl.create(urls: urls.split(/\n/))
    # CHANGME. Do this asynchronously
    c.parallel_fetch 
  end

  get '/crawl/:id' do |id|
    DB[:crawls].first(crawl_id:id).to_json
  end
end

