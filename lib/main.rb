require './boot'

unless ARGV.length == 2
  STDERR.puts "Usage: #{$0} <username> <password>"
  exit 1
end

username = ARGV[0]
password = ARGV[1]

EM.run do
  websocket_connections = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |ws|
    ws.onopen do
      puts "LOG: Websocket connection open"
      websocket_connections << ws
    end

    ws.onclose do
      puts "LOG: Websocket connection closed"
      websocket_connections.delete(ws)
    end
  end

  twitter = TwitterStream.new(username, password, "football,soccer,futebol,futbol").listen

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
  twitter.ontweet do |user, msg|
    websocket_connections.each do |socket|

      ld = LanguageDetector.new(msg)
      ld.callback do |lang|
        JSON.generate(:lang => lang, :user => user, :tweet => msg)
      end

      ld.errback do |lang|
        puts "LOG: Couldn't find language for: ' #{msg}"
        socket.send(JSON.generate(:lang => nil, :user => user, :tweet => msg))
      end
    end
  end
end