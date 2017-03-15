#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'net/http'
require 'json'
require 'logger'
require 'yaml'
require 'twitter'

class FortuneQuote
  def initialize(service_uri, logger)
    @logger = logger
  end

  def get()
    begin
      "#{`fortune -c -n 105 -s`.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')} #quotd"
    rescue StandardError => e
      @logger.error e.message
      return nil
    end
  end    
end

class DoahQuote
  def initialize(service_uri, logger)
    @uri = service_uri + 'pesca'
    @logger = logger
  end
  
  def get
    begin
      body_resp = Net::HTTP.get @uri
      card = JSON.parse body_resp
      if card["status"].downcase == "ok"
        return card["value"]
      else
        logger.warn card["status"]
        return nil
      end
    rescue StandardError => e
      @logger.error e.message
      return nil
    end
  end
end

class BofhQuote
  def initialize(service_uri, logger)
    @uri = service_uri + 'genera'
    @logger = logger
  end
  
  def get
    begin
      body_resp = Net::HTTP.get @uri
      card = JSON.parse body_resp
      if card["status"].downcase == "ok"
        return card["value"]
      else
        logger.warn card["status"]
        return nil
      end
    rescue StandardError => e
      @logger.error e.message
      return nil
    end
  end
end

class TweetMotd
  def initialize
    @logger = Logger.new('tweet-out.log', 10, 1_024_000)
    @logger.level = Logger::INFO
    @logger.progname = 'doah_tweet'
    @next_quote = Date.today
    @quotes = []
    service_uri = URI('http://localhost:9292/')
    @quotes << DoahQuote.new(service_uri, @logger)
    @quotes << BofhQuote.new(service_uri, @logger)
    @quotes << FortuneQuote.new(service_uri, @logger)
    begin
      app_conf = JSON.load(File.open(File.expand_path("#{Dir.pwd}/../config/config.json")))
      @client = Twitter::REST::Client.new do |config|
        tw_conf = app_conf['twitter']
        config.consumer_key = tw_conf['consumer_key']
        config.consumer_secret = tw_conf['consumer_secret']
        config.access_token = tw_conf['oauth_token']
        config.access_token_secret = tw_conf['oauth_token_secret']
      end
    rescue StandardError => e
      @logger.error e.message
    end
  end

  def run
    begin
      while true
        if (@quote.length > 0)
          # let's get first element and then reinsert it as the last one
          quote = @quotes.shift
          @quotes.push quote
          str = "#{quote.get} #Ralphsays"
          @logger.info quote.length
          @client.update(quote) if quote.length < 140
        end
        sleep 43200 / @quotes.length # 12 hours * 60 minutes * 60 seconds / how many generator we have
      end
    rescue StandardError => e
      @logger.error e.message
    ensure
      @logger.close
    end
  end
end
  
## start the app ##
tm = TweetMotd.new
tm.run
