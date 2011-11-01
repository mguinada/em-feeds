require 'twitter/json_stream'

class TwitterStream
  def initialize(user, password, term)
    @user, @password, @term = user, password, term
    @tweet_callbacks = []
    @error_callbacks = []
  end

  def listen
    stream = Twitter::JSONStream.connect(:ssl     => true,
                                         :path    => "/1/statuses/filter.json",
                                         :auth    => "#{@user}:#{@password}",
                                         :method  => 'POST',
                                         :content => "track=#{@term}")

    stream.each_item do |item|
      tweet = JSON.parse(item)
      @tweet_callbacks.each { |c| c.call(tweet['user']['screen_name'], tweet['text'], tweet) }
    end

    stream.on_error do |message|
      @error_callbacks.each { |c| c.call(message) }
    end

    stream.on_max_reconnects do |timeout, retries|
      @error_callbacks.each { |c| c.call("Failed with timeout: #{timeout} after #{retries} retries") }
    end
    self
  end

  def ontweet(&block)
    @tweet_callbacks << block
  end

  def onerror(&block)
    @error_callbacks << block
  end
end