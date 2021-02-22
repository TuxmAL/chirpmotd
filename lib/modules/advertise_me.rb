module ChirpQuote
  class AdvertiseMe
    def initialize(service_uri, logger)
      # AdvertiseMe needs another URI (as string)
      @uri = 'https://tuxmal.net/'
      @logger = logger
    end

    def get
      begin
        @logger.info "#{self.class}: advertising #{@uri} and @TuxmAL"
          return "A @TuxmAL service powered by Raspberry Pi + Raspbian hosted at #{@uri}\nFeel free to contact me!"
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end 
