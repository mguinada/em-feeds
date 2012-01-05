require 'twitter/json_stream'

class TwitterStream
  callbacks :ontweet, :onerror

  def initialize(user, password, term)
    @user, @password, @term = user, password, term
  end

  def listen
    stream = Twitter::JSONStream.connect(:ssl     => true,
                                         :path    => "/1/statuses/filter.json",
                                         :auth    => "#{@user}:#{@password}",
                                         :method  => 'POST',
                                         :content => "track=#{@term}")

    stream.each_item do |item|
      tweet = JSON.parse(item)
      ontweet_callbacks.each { |c| c.call(tweet['user']['screen_name'], tweet['text'], tweet) }
    end

    stream.on_error do |message|
      onerror_callbacks.each { |c| c.call(message) }
    end

    stream.on_max_reconnects do |timeout, retries|
      onerror_callbacks.each { |c| c.call("Failed with timeout: #{timeout} after #{retries} retries") }
    end
    self
  end
end