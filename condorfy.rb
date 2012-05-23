require 'sinatra'

before do
  content_type :html
end

get '/create' do
  @binaries = `ls /usr/bin`.split(/\n/)
  erb :condorfy
end