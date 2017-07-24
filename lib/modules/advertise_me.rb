module ChirpQuote
  class AdvertiseMe
    def initialize(service_uri, logger)
      # AdvertiseMe needs another URI (as string)
      @uri = 'https://tuxmal.noip.me/'
      @logger = logger
    end

    def get
      begin
        @logger.info "#{self.class}: advertising #{@uri} and @TuxmAL"
          return "Service powered by Raspberry Pi + Raspbian and hosted at #{@uri}\nFeel free to contact my master @TuxmAL!"
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end 
