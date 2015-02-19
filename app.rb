require 'rubygems'
require 'sinatra'
require 'httpclient'
require 'nokogiri'
require 'json'

configure do
  set server: 'thin'
  set port: 3000
  set port: '0.0.0.0'
end

helpers do
end

get '/' do
  clnt = HTTPClient.new

  uri = 'http://kdd.cz/'
  query = {
    'login[username]' => params[:u],
    'login[password]' => params[:p]
  }
  res = clnt.post(uri, query)

  uri = 'http://kdd.cz/index.php'
  query = {
    'page' => 'user',
    'lang' => 'en'
  }
  res = clnt.get(uri, query)

  uri = 'http://kdd.cz/index.php'
  query = {
    'page' => 'search',
    'akce' => 'Search',
    'base-search[column]' => 'vse',
    'base-search[language]' => 'all',
    'base-search[count-per-page]' => '99',
    'base-search[string]' => params[:q]
  }
  res = clnt.get(uri, query)

  doc = Nokogiri::HTML res.content
  itms = doc.css('td')

  content_type :json
  json = Array.new
  for i in 0..(itms.count/14)-1
    name = itms[i*14].text
    id = itms[i*14].css('a')[0]['href'].sub(/\?page=doc-detail&id=/, '')
    url = "http://kdd.cz/file.php?id=#{id}"
    json << { book: { name: name, id: id, url: url, author: author } }
  end
  json.to_json
end
