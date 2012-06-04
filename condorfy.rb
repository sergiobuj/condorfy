require 'sinatra'

begin
  require 'sinatra/reloader'
rescue LoadError
  # sinatra-contrib not installed
end

enable :sessions

before do
  content_type :html
end

helpers do
  def titleize(word)
    word.gsub(/^(.)/) { $1.capitalize }
  end
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
  end
  params.delete_if {|_, v| v.empty? }

  is_parallel = false

  is_parallel = true if params[:universe] == "parallel"

  @condorfyle = "#### Auto generated Condor Submission file ####\n"
  @condorfyle << "#### Sergio Botero sbotero2_a_eafit_edu_co ####\n\n\n"

  files_name = params.delete("files_name")
  machine_count = params.delete("jobs_or_cores")

  if is_parallel
    @condorfyle << "#### Number of machines for parallel processing ####\n"
    @condorfyle << "machine_count = #{machine_count}\n"

    @condorfyle << "error = #{files_name}.err.$(NODE)\n"
    @condorfyle << "output = #{files_name}.out.$(NODE)\n"
  else
    @condorfyle << "error = #{files_name}.err.$(PROCESS)\n"
    @condorfyle << "output = #{files_name}.out.$(PROCESS)\n"
  end
  @condorfyle << "log = #{files_name}.log\n"

  ##### Create file #####
  @condorfyle << "#### Other config variables ####\n"
  params.each do | key , value|
    @condorfyle << "#{key} = #{value}\n"
  end

  if is_parallel
    @condorfyle << "queue\n"
  else
    @condorfyle << "queue #{machine_count}\n"
  end

  session["condorfilename"] = params[:files_name]
  session["condorfi"] = @condorfyle
  erb :condorfied
end

get '/getfied' do
  content_type 'application/condor'
  File.open("condor.file.condor", 'w') do |f|
    f.puts( session["condorfi"] )
  end
  send_file("condor.file.condor", :disposition => 'attachment', :filename => "#{session["condorfilename"]}.condor")
end