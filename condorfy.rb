require 'sinatra'

begin
  require 'sinatra/reloader'
rescue LoadError
  # sinatra-contrib not installed
end

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
  end
  params.delete_if {|k, v| v.empty? }
  
  is_parallel = (params[:universe] == "parallel")
  
  @condorfyle = "#### Auto generated Condor Submission file ####\n"
  @condorfyle << "#### Sergio Botero sbotero2_a_eafit_edu_co ####\n\n\n"

  ##### Create file #####
  params.each do | key , value|
    if key == "jobs_or_cores"
      if is_parallel
        @condorfyle << "machine_count = #{value}\n"
      end
    elsif key == "files_name"
      @condorfyle << ((is_parallel)? "error = #{value}.err.$(NODE)\n" : "error = #{value}.err.$(PROCESS)\n")
      @condorfyle << ((is_parallel)? "output = #{value}.out.$(NODE)\n" : "output = #{value}.out.$(PROCESS)\n")
      @condorfyle << "log = #{value}.log\n"
    elsif key == "input_file_content"
      # nil
    else
      @condorfyle << "#{key} = #{value}\n"
    end
    
  end
  
  @condorfyle << ((is_parallel)? "queue\n" : "queue #{params[:jobs_or_cores]}\n")  
  
  puts @condorfyle
  erb :condorfied
end

get '/getfied' do
  
end
