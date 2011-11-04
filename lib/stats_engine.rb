require 'active_support/time'
class Stats
  attr_reader :values

  def initialize(values)
    @values = values.sort { |a, b| a[:time] <=> b[:time] }
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^last_(\d+)_(hours|minutes|seconds)$/
      process_ghost_method($1, $2)
    else
      super
    end
  end

  private
  def process_ghost_method(qty, unit)
    @values.select { |v| v[:time] >= qty.to_i.send(unit).ago }
  end
end

class StatsEngine
  @@twitter_time_format = "%a %b %d %H:%M:%S %Z %Y"
  include EM::Deferrable

  attr_accessor :tweets

  class << self
    def twitter_time(str)
      DateTime.strptime(str, @@twitter_time_format)
    end
  end

  def initialize
    @tweets = {}
  end

  def process_tweet(tweet, lang = nil)
    begin
      t = StatsEngine.twitter_time(tweet['created_at'])

      @tweets[t] ||= { :time => t, :quantity => 0 }
      @tweets[t][:quantity] += 1

      self.succeed(Stats.new(@tweets.values))
    rescue
      self.fail
    end
  end
end