module ChirpQuote
  class BofhQuote
    def initialize(config, logger)
      @logger = logger
      @uri = config['service_uri'].nil? ? '' : config['service_uri']
      @uri = URI.join(@uri, 'genera')
      rescue => e
        @logger.error e.message
        @logger.error e.backtrace
    end

    def get
      begin
        body_resp = Net::HTTP.get @uri
        card = JSON.parse body_resp
        @logger.info "#{self.class}: #{card}"
  #      if card["status"].downcase == "ok"
          return "#devopsay #{card["value"]}"
  #      else
  #        @logger.warn card["status"]
  #        return "Uhm!#{self.class}: #{card["status"]}"
  #      end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end
