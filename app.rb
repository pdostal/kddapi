require 'rubygems'
require 'sinatra'
require 'httpclient'

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
  body = { 'login[username]' => params[:u], 'login[password]' => params[:p] }
  res = clnt.post(uri, body)
  
  uri = 'http://kdd.cz/index.php?page=search&lang=en'
  res = clnt.get(uri, :follow_redirect => true)

  erb :index
end
