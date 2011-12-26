class App < Sinatra::Base
  set :views, File.dirname(__FILE__)  + "/../views"
  set :public_folder, File.dirname(__FILE__) + "/../public"

  puts File.dirname(__FILE__) + "/../public"

  get '/' do
    erb :index
  end
end