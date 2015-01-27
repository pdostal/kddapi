require 'rubygems'
require 'sinatra'
require 'httpclient'
require 'nokogiri'

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
  @itms = doc.xpath('//h4/a')

  erb :index
end
