require 'active_support/time'
class Stats
  attr_reader :tweets_vs_time, :term_hits

  def initialize(tweets_vs_time, term_hits)
    @tweets_vs_time = tweets_vs_time.sort { |a, b| a[:time] <=> b[:time] }
    @term_hits = term_hits
  end

  def self.json_create(o)
    new(*o['data'])
  end

  def to_json(*a)
    { 'tweets_vs_time' => @tweets_vs_time, 'term_hits' => @term_hits }.to_json(*a)
  end

  protected
  def method_missing(method, *args, &block)
    if method.to_s =~ /^last_(\d+)_(hours|minutes|seconds)$/
      process_ghost_method($1, $2)
    else
      super
    end
  end

  private
  def process_ghost_method(qty, unit)
    @tweets_vs_time = @tweets_vs_time.select { |v| v[:time] >= qty.to_i.send(unit).ago }
    self
  end
end

class StatsEngine
  @@twitter_time_format = "%a %b %d %H:%M:%S %Z %Y"
  include EM::Deferrable

  attr_accessor :tweets_vs_time

  class << self
    def twitter_time(str)
      DateTime.strptime(str, @@twitter_time_format)
    end
  end

  def initialize(terms = nil)
    @tweets_vs_time = {}
    @term_hits = {}
    @terms = terms
  end

  def process_tweet(tweet, lang = nil)
    begin
      t = StatsEngine.twitter_time(tweet['created_at'])

      tweet_vs_time_count(t)
      term_hit_count(tweet) unless @terms.nil?

      self.succeed(Stats.new(@tweets_vs_time.values, @term_hits.values))
    rescue
      self.fail
    end
  end

  private
  def tweet_vs_time_count(t)
    @tweets_vs_time[t] ||= { time: t, quantity: 0 }
    @tweets_vs_time[t][:quantity] += 1
    @tweets_vs_time[t]
  end

  def term_hit_count(tweet)
    matches = tweet['text'].scan(Regexp.new("#{@terms.split(",").join("|")}", Regexp::IGNORECASE))
    unless matches.nil?
      matches.to_a.map(&:downcase).each do |match|
        puts match
        @term_hits[match] ||= { term: match, quantity: 0 }
        @term_hits[match][:quantity] += 1
      end
    end
  end
end