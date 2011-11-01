require './boot'

unless ARGV.length == 2
  STDERR.puts "Usage: #{$0} <username> <password>"
  exit 1
end

username = ARGV[0]
password = ARGV[1]

EM.run do
  web_socket_server = WebSocketServer.new('0.0.0.0', 8080)
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
    web_socket_server.oneach_connection do |conn|
      ld = LanguageDetector.new(msg)
      ld.callback do |lang|
        conn.send(JSON.generate(:lang => lang, :user => user, :tweet => msg))
      end

      ld.errback do |lang|
        puts "LOG: Couldn't find language for: ' #{msg}"
        conn.send(JSON.generate(:lang => nil, :user => user, :tweet => msg))
      end
    end
  end
end