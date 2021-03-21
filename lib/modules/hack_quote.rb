# encoding: utf-8
# hack_quote.rb

# This module gets some quotes from http://hackersays.com/quotes.
# These quotes are buffered and served through my Sinatra API server. They are interleaved (once everey every 5 quotes) with 
# an acknowledgement to the http://hackersays.com/ authors.
module ChirpQuote

  class HackQuote
    def initialize(config, logger)
      @logger = logger
      @uri = config['service_uri'].nil? ? '' : config['service_uri']
      @uri = URI.join(@uri, 'cita')
      rescue => e
        @logger.error e.message
        @logger.error e.backtrace
    end

    def get
      begin
        body_resp = Net::HTTP.get @uri
        quote = JSON.parse body_resp
        @logger.info "#{self.class}: #{quote}"
        if quote["status"].downcase == "ok"
          return "#hackersays #{quote["value"]}"
        else
          @logger.warn quote["status"]
          return "Uhm! #{self.class}: #{quote["status"]}"
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end 
