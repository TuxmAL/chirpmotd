# frozen_string_literal: true

module ChirpQuote
  class DiceGenerator
    def initialize(config, logger)
      @logger = logger
      @sides = 6
      @dices = 2
      @uri = config['service_uri'].nil? ? '' : config['service_uri']
      @uri = URI.join(@uri, "lancia/#{@dices}?faces=#{@sides}")
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
    end

    def get(double_nuts = false)
      body_resp = Net::HTTP.get @uri
      result = JSON.parse body_resp
      @logger.info "#{self.class}: #{result}"
      if double_nuts
        "#{fancy_graph(result['throw'])} (you got #{result['value']})"
      else
        second_throw = "<br>Double nuts!<br>So... let's roll again<br>" + get(true) if double_nuts?(result['throw'])
        "#DiceRoll Let's roll #{@dices} #{@sides}-sided dice: #{fancy_graph(result['throw'])} (you got #{result['value']})#{second_throw}"
      end
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
          roll_result == 1 ? "\u1F464 (head)" : 'ξ (tail)'
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

    def double_nuts?(roll_results)
      roll_results.size != 1 && roll_results.uniq.size == 1
    end
  end
end
