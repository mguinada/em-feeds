#TODO: Reimplement scroll code
#TODO: Channel replacement
#TODO: Web form validation
#TODO: Treat wrong login
EM.run do
  # hit Control + C to stop
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  channels = Channels.instance

  websocket_server = WebSocketServer.new('0.0.0.0', 3001)
  channels.websocket_server = websocket_server

  #channel binding
  websocket_server.on_message do |session_id, conn|
    if channels[session_id].present?
      channels[session_id].bind_connection(conn)
      puts "started data push for feed #{session_id}"
    end
  end

  #data push
  channels.on_message do |channel, handle, tweet, stats|
    websocket_server.on_each_connection do
      channel.push(JSON.generate(:handle => handle, :tweet => tweet, :stats => stats.last_60_seconds))
    end
  end

  Thin::Server.start SinatraApp, '0.0.0.0', 3000
end
