module ChirpQuote
  class BofhQuote
    def initialize(service_uri, logger)
      @uri = service_uri + 'genera'
      @logger = logger
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