require 'sinatra'
require 'sinatra/reloader'

before do
  content_type :html
end

get '/create' do
  @binaries = `ls /usr/bin`.split(/\n/)
  @max_num_jobs = 200
  erb :form
end


post '/condorfy' do
  @sub_file = "bla bla bla"
  erb :condorfied
end
