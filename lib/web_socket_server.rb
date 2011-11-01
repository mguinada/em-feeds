class WebSocketServer
  attr_reader :connections

  def initialize(host, port)
    @connections = []

    EM::WebSocket.start(:host => host, :port => port) do |ws|
      ws.onopen do
        puts "LOG: Websocket connection open"
        @connections << ws
      end

      ws.onclose do
        puts "LOG: Websocket connection closed"
        @connections.delete(ws)
      end
    end
  end

  def oneach_connection(&block)
    @connections.each { |conn| block.call(conn) }
  end

  def send(data)
    oneach_connection { |conn| conn.send(data) }
  end
end