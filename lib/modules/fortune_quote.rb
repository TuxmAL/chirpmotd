module ChirpQuote
  class FortuneQuote
    def initialize(service_uri, logger)
      @logger = logger
    end

    def get()
      begin
        text = "#quotd #{`fortune -c -n 105 -s`.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')}"
        @logger.info "#{self.class}: #{text}"
        return text
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end
