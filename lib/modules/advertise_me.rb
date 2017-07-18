module ChirpQuote
  class AdvertiseMe
    def initialize(service_uri, logger)
      @uri = service_uri
      @logger = logger
    end

    def get
      begin
        @logger.info "#{self.class}: advertising #{@uri} and @TuxmAL"
          return "This service was made by @TuxmAL, proudly powered by Raspberry Pi + Raspbian, and hosted at #{@uri}\nFeel free to contanct my master!"
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end 
