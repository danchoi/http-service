require 'sequel'


DB = Sequel.connect 'postgres:///http-service'

module Database
  def self.create_request(res)
    unless DB[:urls].first(url: res[:url])
      DB[:urls].insert url: res[:url]
    end
    last = DB[:requests].filter(url: res[:url]).order(:created.desc).first
    if last && last[:created] > (Time.now - (60 * 10))
      puts "Recently fetched url: #{res[:url]}"
    else
      DB[:requests].insert res
    end
  rescue
    puts $!
  end
end
