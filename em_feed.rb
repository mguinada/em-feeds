require './lib/boot'

#TODO: Allow to define the time range for charted tweets at the web console
#TODO: Pass search terms by command line
#TODO: Reimplement scroll code
#TODO: Solved layout flicker
#TODO: More stats (Language bar / pie graph)
#TODO: Better command line args processing (e.g.: ** for password)
#TODO: Solve JS Error

unless ARGV.length == 2
  STDERR.puts "Usage: #{$0} <username> <password>"
  exit 1
end

EM.run do
  username = ARGV[0]
  password = ARGV[1]

  term = "ruby,clojure,scala,python,java,php"
  statistics_engine = StatsEngine.new(term)
  web_socket_server = WebSocketServer.new('0.0.0.0', 8080)
  twitter = TwitterStream.new(username, password, term).listen

  #Web output
  twitter.ontweet do |user, msg, tweet|
    web_socket_server.oneach_connection do |conn|
      conn.send(JSON.generate(:user => user, :tweet => msg, :stats => statistics_engine.process_tweet(tweet).last_60_seconds, :lang => nil))
    end
  end

  Thin::Server.start App, '0.0.0.0', 3000
end