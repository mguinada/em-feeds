require './lib/boot'

#TODO: Reimplement scroll code
#TODO: Channel replacement
#TODO: Web form validation
#TODO: Session termination
EM.run do
  web_socket_server = WebSocketServer.new('0.0.0.0', 3001)

  channels = Channels.instance
  channels.onmessage do |channel, handle, tweet, stats|
    puts "From #{channel}: #{handle} - #{tweet}"
  end

  channels.onerror do |channel, msg|
    puts "From #{channel}: [ERROR] #{msg}"
  end

  #Web output
  channels.onmessage do |channel, handle, tweet, stats|
    web_socket_server.oneach_connection do |conn|
      conn.send(JSON.generate(:handle => handle, :tweet => tweet, :stats => stats.last_60_seconds))
    end
  end

  Thin::Server.start App, '0.0.0.0', 3000
end
