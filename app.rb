require 'rubygems'
require 'sinatra'

configure do
  set server: 'thin'
  set port: 3000
  set port: '0.0.0.0'
end

helpers do
end

get '/' do
  erb '{"welcome":"Hello World!"}'
end
