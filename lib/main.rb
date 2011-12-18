require './boot'

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

username = ARGV[0]
password = ARGV[1]

EM.run do
  term = "futebol,futbol,soccer,champions,benfica,manunited,realmadrid,barca"
  statistics_engine = StatsEngine.new(term)
  web_socket_server = WebSocketServer.new('0.0.0.0', 8080)
  twitter = TwitterStream.new(username, password, term).listen

  #Console output
  twitter.ontweet do |user, msg, tweet|
    ld = LanguageDetector.new(msg)
    ld.callback do |lang|
      puts "[#{lang}] @#{user}: #{msg}"
    end

    ld.errback do |lang|
      puts "@#{user}: #{msg}"
    end
  end

  #Web output
  twitter.ontweet do |user, msg, tweet|
    #TODO: Watch this
    statistics_engine.process_tweet(tweet)
    statistics_engine.callback do |stats|
      web_socket_server.oneach_connection do |conn|
        conn.send(JSON.generate(:user => user, :tweet => msg, :stats => stats.last_60_seconds, :lang => nil))
      end
    end
  end
end