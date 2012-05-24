require 'sinatra'
require 'sinatra/reloader'

before do
  content_type :html
end


['/', '/create/?'].each do |req|
  get req do
    @binaries = `ls /usr/bin`.split(/\n/)
    @max_num_jobs = 200
    erb :form
  end
end

post '/condorfy/?' do
  params.keys.each do |key|
    params[key].strip!
    params.reject! {|key, value| value.nil? }
  end
  
  params.keys.each do |key|
    puts "-#{key}--#{params[key]}-"
  end


  erb :condorfied
end
