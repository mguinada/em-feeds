class SinatraApp < Sinatra::Base
  enable :sessions

  set :views, File.dirname(__FILE__)  + "/../views"
  set :public_folder, File.dirname(__FILE__) + "/../public"

  get '/' do
    erb :index
  end

  post '/feed' do
    EM.next_tick do
      Channels.instance.create(session[:session_id], params[:username], params[:password], params[:terms])
    end

    erb :feed
  end
end