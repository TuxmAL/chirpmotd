module ChirpQuote
  class AdvertiseMe
    def initialize(config, logger)
      @logger = logger
      @uri = config['service_uri'].nil? ? 'https://tuxmal.net/' : config['service_uri']
      rescue => e
        @logger.error e.message
        @logger.error e.backtrace
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
