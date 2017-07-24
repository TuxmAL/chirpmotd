#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'net/http'
require 'json'
require 'logger'
require 'yaml'
require_relative 'twitter_mock'

require_relative '../lib/version.rb'
Dir['../lib/modules/*.rb'].each {|file| require_relative(file)}

module ChirpQuote
  class ChirpMotd
    MAX_DIGIT = 5

    def initialize
      log_filename = File.expand_path("#{__dir__}/../log/#{__FILE__}.log")
      config_filename = File.expand_path("#{__dir__}/../config/config.json")
      @logger = Logger.new(log_filename, 10, 1_024_000)
      @logger.progname = __FILE__
      @logger.level = Logger::DEBUG

      @logger.info "# version #{version}; ChirpQuote::VERSION #{ChirpQuote::VERSION}"

      begin
        app_conf = JSON.load(File.open(config_filename))
        service_uri = URI(app_conf['service_uri'])

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
        @logger.debug "# module class loaded: #{c}"
      end
      @logger.debug "# now deleting #{self.class.name.split('::').last.to_sym}"
      modules.delete self.class.name.split('::').last.to_sym
      @logger.debug "# modules found #{modules.length}."
      @quotes = []
      modules.each do |c|
        @logger.debug "# instantiating module #{c}..."
        # AdvertiseMe needs another URI (as string)
        @quotes << ChirpQuote.const_get(c).new(uri, @logger)
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
          open('/var/lib/chirpmotd.idx', File::CREAT|File::RDWR) do |f|
            idx = (f.read(MAX_DIGIT)).to_i
            @logger.debug "# last index: #{idx}."
            idx = idx % @quotes.length
            @logger.debug "# new index: #{idx} (mod #{@quotes.length})."
            quote = @quotes[idx]
            text = quote.get
            @logger.info "#{text.length}: #{text}"
            chunks = split_text text
            chunks.each {|chunk| @client.update(chunk)}
            f.rewind
            idx += 1
            @logger.debug "# updating index to: #{idx}."
            f.write idx
          end
        else
          @logger.warn "No quote modules found, exiting!"
        end
      rescue StandardError => e
        @logger.error e.message
        @logger.error e.backtrace
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
cm = ChirpQuote::ChirpMotd.new
cm.cron_run
