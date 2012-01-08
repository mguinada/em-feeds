class WebsocketServer
  callbacks :on_new_connection, :on_connection_closed, :on_message
  attr_reader :connections

  def initialize(host, port)
    @connections = []

    EM::WebSocket.start(:host => host, :port => port) do |ws|
      ws.onopen do
        puts "new websocket connection"
        @connections << ws
        on_new_connection_callbacks.each { |c| c.call(ws) }
      end

      ws.onmessage do |msg|
        on_message_callbacks.each { |callback| callback.call(msg, ws) }
      end

      ws.onclose do
        puts "websocket connection closed"
        @connections.delete(ws)
        on_connection_closed_callbacks.each { |callback| callback.call(ws) }
      end
    end
  end

  def on_each_connection(&block)
    @connections.each { |conn| block.call(conn) }
  end

  def send(data)
    on_each_connection { |conn| conn.send(data) }
  end
end