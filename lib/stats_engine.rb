
class StatsEngine
  attr_accessor :tweets

  def initialize
    @tweets = {}
  end

  def process_tweet(tweet, lang = nil)
    #@tweets[tweet['created_at']].nil? ? @tweets[tweet['created_at']] = 1 : @tweets[tweet['created_at']] += 1
    if @tweets[tweet['created_at']].nil?
      @tweets[tweet['created_at']] = { :time => tweet['created_at'], :quantity => 1 }
    else
      @tweets[tweet['created_at']][:quantity] += 1
    end
  end

  def tweet_stats
    @tweets.values
  end
end