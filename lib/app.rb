require 'sinatra'
require 'sequel'
require 'json'

DB = Sequel.connect 'postgres:///http-service'

class HttpService < Sinatra::Application
  post '/crawls' do
  end

  get '/crawl/:id' do |id|
    DB[:crawls].first(crawl_id:id).to_json
  end
end

