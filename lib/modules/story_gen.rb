# frozen_string_literal: true

module ChirpQuote
  class StoryGenerator
    def initialize(service_uri, logger)
      @uri = service_uri + 'racconta'
      @logger = logger
    end

    def get
      body_resp = Net::HTTP.get @uri
      story = JSON.parse body_resp
      @logger.info "#{self.class}: #{story}"
      "#FoleInformatiche #{story['value']}"
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      "Uh-oh! #{self.class}: #{e.message}"
    end
  end
end
