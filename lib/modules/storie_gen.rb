# frozen_string_literal: true

module ChirpQuote
  class StorieGenerator
    def initialize(config, logger)
      @logger = logger
      @uri = config['service_uri'].nil? ? '' : config['service_uri']
      @uri = URI.join(@uri, 'racconta')
      rescue => e
        @logger.error e.message
        @logger.error e.backtrace
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
