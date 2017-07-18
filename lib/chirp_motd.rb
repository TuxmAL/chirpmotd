#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'net/http'
require 'json'
require 'logger'
require 'yaml'
require 'twitter'

Dir[__dir__ + '/modules/*.rb'].each {|file| require_relative file}

module ChirpQuote
  class ChirpMotd
    def initialize
      log_filename = "#{File.expand_path("#{File.dirname(__FILE__)}/../log")}/#{__FILE__}.log"
      config_filename = "#{File.expand_path("#{File.dirname(__FILE__)}/../config/config.json"}"
      @logger.progname = __FILE__
      @logger = Logger.new(log_filename, 10, 1_024_000)
      @logger.level = Logger::INFO

      service_uri = URI('http://tuxmal.loc:9292/')

      # Selecting only classes from modules
      modules = ChirpQuote.constants.select do |c|
        ChirpQuote.const_get(c).is_a? Class 
      end
      modules.delete self.to_sym
      @quotes = []
      modules.each each do |c|
        # AdvertiseMe needs another URI (as string)
        uri = (c != :AdvertiseMe)? service_uri : 'https://tuxmal.noip.me/'
        @quotes << ChirpQuote.const_get(c).new(uri, @logger)
      end
      begin
        app_conf = JSON.load(File.open(config_filename))
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
          open('/var/lib/quotd.idx', "w+") do |f|
            idx = (f.readline).atoi % @quotes.length
            quote = @quotes[idx]
            text = quote.get
            @logger.info "#{text.length}: #{text}"
            chunks = split_text text
            chunks.each {|chunk| @client.update(chunk)}
            f.rewind
            f.write "#{idx++}"
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
