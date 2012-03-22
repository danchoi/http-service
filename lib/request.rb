require 'sequel'
DB = Sequel.connect 'postgres:///http-service'

module Database
  def self.create_request(res)
    unless DB[:urls].first(url: res[:url])
      DB[:urls].insert url: res[:url]
    end
    DB[:requests].insert res
  rescue
    puts $!
    puts $!.backtrace
  end

  def self.recently_fetched?(url)
    last = DB[:requests].filter(url: url).order(:created.desc).first
    last && last[:created] > (Time.now - (60 * 10))
  end
end
