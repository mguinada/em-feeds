require "singleton"

class Channels
  include Singleton

  callbacks :onmessage, :onerror

  def initialize
    @channels = {}
  end

  def create(id, username, password, term)
    if @channels[id].blank?
      rtf = RealTimeFeed.new(TwitterStream.new(username, password, term), StatsEngine.new(term))

      rtf.ontweet do |handle, tweet, stats, meta_tweet|
        onmessage_callbacks.each { |c| c.call(id, handle, tweet, stats, meta_tweet) }
      end

      rtf.onerror do |msg|
        onerror_callbacks.each { |c| c.call(id, msg) }
      end

      @channels[id] = rtf
      rtf.listen
    else
      onerror_callbacks.each { |c| c.call(id, "Channel already present") }
    end
  end
end

class RealTimeFeed
  callbacks :ontweet, :onerror

  def initialize(twitter_feed, stats_engine)
    @twitter_feed = twitter_feed
    @stats_engine = stats_engine
  end

  def listen
    @twitter_feed.ontweet do |handle, tweet, meta_tweet|
      ontweet_callbacks.each do |callback|
        callback.call(handle, tweet, @stats_engine.process_tweet(meta_tweet), meta_tweet)
      end
    end

    @twitter_feed.onerror do |msg|
      onerror_callbacks.each { |callback| callback.call(msg) }
    end

    @twitter_feed.listen
  end
end