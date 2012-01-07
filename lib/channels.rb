require "singleton"
class RealTimeFeed < EM::Channel
  callbacks :on_tweet, :on_error, :on_unsubscribe

  def initialize(twitter_feed, stats_engine)
    super()
    @twitter_feed = twitter_feed
    @stats_engine = stats_engine
    @sid = nil
  end

  def bind_connection(conn)
    @connection = conn
    @sid = subscribe { |msg| conn.send(msg) }
    puts "Channel subscribed."
  end

  def websocket_server(wss)
    wss.on_connection_closed do |conn|
      if @connection == conn
        unsubscribe(@sid)
        on_unsubscribe_callbacks.each { |c| c.call(@connection, @sid) }
        puts "Channel unsubscribed."
      end
    end
  end

  def listen
    @twitter_feed.on_tweet do |handle, tweet, meta_tweet|
      on_tweet_callbacks.each do |callback|
        callback.call(self, handle, tweet, @stats_engine.process_tweet(meta_tweet), meta_tweet)
      end
    end

    @twitter_feed.on_error do |msg|
      on_error_callbacks.each { |callback| callback.call(self, msg) }
    end

    @twitter_feed.listen
  end

  def stop
    @twitter_feed.stop
  end
end

class Channels
  include Singleton
  callbacks :on_message, :on_error
  attr_accessor :websocket_server

  def initialize
    @channels = {}
  end

  def [](key)
    @channels[key]
  end

  def create(id, username, password, term)
    if @channels[id].blank?
      rtf = RealTimeFeed.new(TwitterStream.new(username, password, term), StatsEngine.new(term))

      rtf.on_tweet do |channel, handle, tweet, stats, meta_tweet|
        on_message_callbacks.each { |callback| callback.call(channel, handle, tweet, stats, meta_tweet) }
      end

      rtf.on_error do |channel, msg|
        on_error_callbacks.each { |callback| callback.call(channel, msg) }
      end

      rtf.on_unsubscribe do
        ch = @channels.delete(id)
        ch.stop
        puts "Stopped feed #{id}"
      end

      rtf.websocket_server(websocket_server) if websocket_server

      @channels[id] = rtf
      rtf.listen
    else
      on_error_callbacks.each { |callback, channel| callback.call(channel, "Channel already present") }
    end
  end
end

