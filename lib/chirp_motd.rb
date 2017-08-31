#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'net/http'
require 'json'
require 'logger'
require 'yaml'
require 'twitter'

require_relative 'version.rb'
Dir[__dir__ + '/modules/*.rb'].each {|file| require_relative file}

module ChirpQuote
  class ChirpMotd
    MAX_DIGIT = 5

    def initialize
      basename = self.class.name.split('::').last.downcase
      log_filename = File.expand_path("/var/log/#{basename}.log")
      config_filename = File.expand_path("#{__dir__}/../config/config.json")
      @logger = Logger.new(log_filename, 10, 1_024_000)
      @logger.progname = basename
      @logger.level = Logger::ERROR

      @logger.info "# version #{version}; ChirpQuote::VERSION #{ChirpQuote::VERSION}"
      begin
        unless Dir.exist? "/var/lib/#{basename}"
            Dir.mkdir "/var/lib/#{basename}"
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
      end

      begin
        app_conf = JSON.load(File.open(config_filename))
        @logger.debug "# URI #{app_conf['service_uri']}"
        service_uri = URI(app_conf['service_uri'])
        @logger.debug "# URI #{service_uri}"

        @client = Twitter::REST::Client.new do |config|
          tw_conf = app_conf['twitter']
          config.consumer_key = tw_conf['consumer_key']
          config.consumer_secret = tw_conf['consumer_secret']
          config.access_token = tw_conf['oauth_token']
          config.access_token_secret = tw_conf['oauth_token_secret']
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
      end

      # Selecting only classes from modules
      modules = ChirpQuote.constants.select do |c|
        ChirpQuote.const_get(c).is_a? Class
      end
      modules.delete self.class.name.split('::').last.to_sym
      @quotes = []
      modules.each do |c|
        @quotes << ChirpQuote.const_get(c).new(service_uri, @logger)
      end
    end

    def run
      begin
  #      i = 0
  #      while (++i < 6)
        while true
          if (@quotes.length > 0)
            # let's get first element and then reinsert it as the last one
            quote = @quotes.shift
            @quotes.push quote
            text = quote.get
            @logger.info "#{text.length}: #{text}"
            chunks = split_text text
            chunks.each {|chunk| @client.update(chunk)}
          end
          # test mode start
          #        sleep 360 / @quotes.length # 12 hours * 60 minutes * 60 seconds / how many generator we have
          # test mode end
          sleep 86400 / @quotes.length # 12 hours * 60 minutes * 60 seconds / how many generator we have
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
      ensure
        @logger.close
      end
    end

    def cron_run
      begin
        if (@quotes.length > 0)
          open('/var/lib/chirpmotd/chirpmotd.idx', File::CREAT|File::RDWR) do |f|
            idx = (f.read(MAX_DIGIT)).to_i % @quotes.length
            quote = @quotes[idx]
            text = quote.get
            @logger.info "#{text.length}: #{text}"
            chunks = split_text text
            chunks.each {|chunk| @client.update(chunk)}
            f.rewind
            idx += 1
            f.write idx
          end
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
      ensure
        @logger.close
      end
    end

    private

    def split_text(text)
      if text.length < 120
        [text]
      else
        words = text.split
        chunks = []
        num = 1
        until words.empty?
          chunk = "#{num}/§"
          word = words.shift
          while !word.nil? and ((chunk + word).length + 1 < 120)
            chunk += " #{word}"
            word = words.shift
          end
          num += 1
          chunks << "#{chunk}..."
          words.unshift word unless word.nil?
        end
        chunks.each {|chunk| chunk[2] = (num - 1).to_s}
        chunk = chunks.pop
        chunk.chop!.chop!.chop! #remove last three dot, added previously.
        chunks.push chunk
        return chunks
      end
    end
  end
end

