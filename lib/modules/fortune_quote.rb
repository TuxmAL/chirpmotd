#frozen_string_literal: true

module ChirpQuote
  class FortuneQuote
    def initialize(config, logger)
      @logger = logger
      path = config['fortune_path'].nil? ? '' : config['fortune_path']
      @fortune_cmd = Pathname(path).join 'fortune'
      rescue => e
        @logger.error e.message
        @logger.error e.backtrace
    end

    def get
      begin
        fortune = `#{@fortune_cmd} -c -n 105 -s`
        fortune.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace)
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
