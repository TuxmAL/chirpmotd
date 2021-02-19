# frozen_string_literal: true

module ChirpQuote
  class DiceGenerator
    def initialize(service_uri, logger)
      @sides = 6
      @dices = 2
      @uri = service_uri + "lancia/#{@dices}?faces=#{@sides}"
      @logger = logger
    end

    def get
      body_resp = Net::HTTP.get @uri
      result = JSON.parse body_resp
      @logger.info "#{self.class}: #{result}"
      "#DiceRoll Let's roll #{@dices} #{@sides}-sided dice: #{fancy_graph(result['throw'])} (you got #{result['value']})"
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      "Uh-oh! #{self.class}: #{e.message}"
    end

    private

    def fancy_graph(roll_results)
      msg = roll_results.map do |roll_result|
        case @sides
        when 2
          if roll_result == 1
            "\u1F464 (head)"
          else
            "ξ (tail)"
          end
        when 6
          dice = "\u267f"
          roll_result.times { dice = dice.succ }
          dice
        else
          roll_result.to_s
        end
      end
      msg.join(' ')
    end
  end
end
