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
      text = "#{`fortune -c -n 105 -s`.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')} #quotd"
      @logger.info "#{self.class}: #{text}"
      return text
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      return "Uh-oh! #{self.class}: #{e.message}"
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
      @logger.info "#{self.class}: #{card}"
      if card["status"].downcase == "ok"
        return "#Ralphsays #{card["value"]}"
      else
        @logger.warn card["status"]
        return "Uhm! #{self.class}: #{card["status"]}"
      end
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      return "Uh-oh! #{self.class}: #{e.message}"
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
      @logger.info "#{self.class}: #{card}"
#      if card["status"].downcase == "ok"
        return "#devopsay #{card["value"]}"
#      else
#        @logger.warn card["status"]
#        return "Uhm!#{self.class}: #{card["status"]}"
#      end
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      return "Uh-oh! #{self.class}: #{e.message}"
    end
  end
end

class Bofh2Quote
  def initialize(service_uri, logger)
    @uri = service_uri + 'estrai'
    @logger = logger
  end

  def get
    begin
      body_resp = Net::HTTP.get @uri
      card = JSON.parse body_resp
      @logger.info "#{self.class}: #{card}"
#      if card["status"].downcase == "ok"
        return "#bhofsay #{card["value"]}"
#      else
#        @logger.warn card["status"]
#        return "Uhm!#{self.class}: #{card["status"]}"
#      end
    rescue StandardError => e
      @logger.error e.message
      @logger.error e.backtrace
      return "Uh-oh! #{self.class}: #{e.message}"
    end
  end
end

class TweetMotd
  def initialize
    @logger = Logger.new('tweet-out.log', 10, 1_024_000)
    @logger.level = Logger::INFO
    @logger.progname = 'quotd_tweet'
    @quotes = []

    service_uri = URI('http://tuxmal.local:9292/')
    @quotes << DoahQuote.new(service_uri, @logger)
    @quotes << BofhQuote.new(service_uri, @logger)
    @quotes << FortuneQuote.new(service_uri, @logger)
    @quotes << Bofh2Quote.new(service_uri, @logger)
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
          chunk = split_text text
          for chunk in chunks
            @client.update(chunk)
          end
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

## start the app ##
tm = TweetMotd.new
tm.run
