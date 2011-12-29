class App < Sinatra::Base
  enable :sessions

  set :views, File.dirname(__FILE__)  + "/../views"
  set :public_folder, File.dirname(__FILE__) + "/../public"

  get '/' do
    erb :index
  end

  post '/feed' do
    puts "---------------"
    puts params.inspect
    puts session.inspect
    puts "---------------"
  end
end