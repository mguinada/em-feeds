require 'twitter/json_stream'

class TwitterStream
  callbacks :on_tweet, :on_error

  def initialize(user, password, term)
    @user, @password, @term = user, password, term
  end

  def listen
    @stream = Twitter::JSONStream.connect(:ssl     => true,
                                          :path    => "/1/statuses/filter.json",
                                          :auth    => "#{@user}:#{@password}",
                                          :method  => 'POST',
                                          :content => "track=#{@term}")

    @stream.each_item do |item|
      tweet = JSON.parse(item)
      on_tweet_callbacks.each { |c| c.call(tweet['user']['screen_name'], tweet['text'], tweet) }
    end

    @stream.on_error do |message|
      on_error_callbacks.each { |c| c.call(@stream.code, message) }
    end

    @stream.on_max_reconnects do |timeout, retries|
      on_error_callbacks.each { |c| c.call(@stream.code, "Failed with timeout: #{timeout} after #{retries} retries") }
    end
    self
  end

  def stop
    @stream.stop
  end
end