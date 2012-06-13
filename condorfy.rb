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

  def unspace(word)
    word.sub(" ", "_" )
  end
end

['/', '/create/?'].each do |req|
  get req do
    @binaries = File.read("adminbins").split(/\n/)
    @max_num_jobs = 200
    erb :form
  end
end

post '/condorfy/?' do
  params.keys.each do |key|
    params[key].strip! if params[key].respond_to?(:strip!)
  end

  params.delete_if {|_, v| v.empty? }

  is_parallel = false

  is_parallel = true if params[:universe] == "parallel"

  @condorfyle = "#### Generated Condor Submission file ####\n"
  @condorfyle << "#### APOLO eafit COL ####\n\n"

  files_name = unspace params.delete("files_name")
  machine_count = params.delete("jobs_or_cores")

  env_names  = params.delete("env_names")
  env_values = params.delete("env_values")

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

  customexec = params.delete("real_bin_path")
  unless customexec.nil?
    params.delete("executable")
    @condorfyle << "executable = #{customexec}\n"
  end

  @files_name = files_name
  @input_file_content = params.delete("input_file_content")

  ##### Handle requirements #####
  reqs = []
  opsys = params.delete("required_opsys")
  unless opsys.nil?
    reqs.push("OpSys == \"#{opsys}\"")
  end
  memory = params.delete("required_memory")
  unless memory.nil?
    reqs.push("Memory >= #{memory}")
  end
  arch = params.delete("required_arch")
  unless arch.nil?
    reqs.push("Arch == \"#{arch}\"")
  end

  unless reqs.empty?
    @condorfyle << "requirements = #{reqs.join(" && ")}\n"
  end  
  
  ##### Create file #####
  @condorfyle << "\n#### Other config variables ####\n"
  params.each do | key , value|
    @condorfyle << "#{key} = #{value}\n"
  end

  unless env_names.nil?
    @condorfyle << "\n\n#### Environment Variables ####\n"
    @condorfyle << "environment = #{env_names.zip(env_values).map{|x| x.join("=")}.join(';')}\n"
  end

  if is_parallel
    @condorfyle << "queue\n"
  else
    @condorfyle << "queue #{machine_count}\n"
  end
  
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
