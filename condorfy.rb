#require 'sinatra'
require 'sinatra'
require 'rubygems'
require 'bundler'
require 'yaml'
require './engine.rb'
require 'bundler/setup'
environment = ENV['RACK_ENV'] || 'development'
Bundler.require(:default, environment.to_sym)

begin
  require 'sinatra/reloader'
rescue LoadError
  #sinatra-contrib not installed
  puts "Sintra Contrib not installed"
end

enable :sessions

before do
  content_type :html
end

helpers do
  def titleize(word)
    word.gsub(/^(.)/) { $1.capitalize }
  end

  def unspace(word)
    unless word.nil?
      word.gsub(" ", "_" )
    end
  end
end

['/', '/create/?', 'condorfy/?'].each do |req|
  get req do
    yconfig = YAML.load_file("config.yaml")
    @binaries = yconfig["bins"]
    @archs = yconfig["arch"]
    @opsys = yconfig["opsys"]
    @max_num_jobs = 200
    erb :form
  end
end

post '/condorfy/?' do
  @condorfyle = create_super_fyle(params)
  session["condorfi"] = @condorfyle
  
  erb :condorfied

end

get '/download/:filename' do

  content_type 'application/condor'
  temp = Tempfile.new("condor.file.condor")
  temp.write( session["condorfi"] )
  temp.close

  send_file(temp.path , :disposition => 'attachment', :filename => "#{params[:filename]}.condor")

  temp.unlink
end
