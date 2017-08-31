module ChirpQuote
  class FortuneQuote
    def initialize(service_uri, logger)
      @logger = logger
    end

    def get()
      begin
        fortune = `fortune -c -n 105 -s -u`
        fortune.encode!(Encoding::UTF_8, {:invalid => :replace, :undef => :replace})
        text = "#quotd #{fortune.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')}"
        @logger.info "#{self.class}: #{text}"
        return text
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
        @logger.error "offending text:\n #{text.inspect}"
        return "Uh-oh! #{self.class}: #{e.message}"
      end
    end
  end
end
