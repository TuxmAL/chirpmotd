module ChirpQuote
  require 'mqtt'

  class ItsMe
    def initialize(config, logger)
      @logger = logger
      @uri = (config['mqtt_uri'].nil? ? '' : config['mqtt_uri'])
    end

    def get
      begin
        @logger.info "#{self.class}: advertising RaspyTux status to @TuxmAL"
        text = ''
        MQTT::Client.connect(@uri) do |c|
          _, time = c.get '/tuxmalrpi/temp/time'
          _, gpu_temp = c.get '/tuxmalrpi/temp/gpu'
          _, cpu_temp = c.get '/tuxmalrpi/temp/cpu'
          _, throttle = c.get '/tuxmalrpi/temp/trottle_decoded'
          text = "@TuxmAL, here RaspyTux: my CPU #{cpu_temp}, my GPU #{gpu_temp} at #{time}.\n#{throttle.gsub!('\\n',"\n").chomp!}"
        end
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
