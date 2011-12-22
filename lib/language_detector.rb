require './lib/boot'

class LanguageDetector
  URL = 'http://www.google.com/uds/GlangDetect'

  include EM::Deferrable

  def initialize(text)
    request = EM::HttpRequest.new(URL).get(:query => {:v => '1.0', :q => text})

    request.callback do
      if request.response_header.status == 200
        info = JSON.parse(request.response)["responseData"]
        if info and info['isReliable']
          self.succeed(info['language'])
        else
          self.fail("Language couldn't be detected")
        end
      else
        self.fail("API Call error")
      end
    end

    request.errback do
      self.fail("Error making API call")
    end
  end
end