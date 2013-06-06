#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'yaml'
require 'twitter'

APP_CONF = YAML.load(File.open(File.expand_path("#{Dir.pwd}/../config/config.yml")))

Twitter.configure do |config|
  tw_conf = APP_CONF['twitter']
  config.consumer_key = tw_conf[:consumer_key]
  config.consumer_secret = tw_conf[:consumer_secret]
  config.oauth_token = tw_conf[:oauth_token]
  config.oauth_token_secret = tw_conf[:oauth_token_secret]
end

def quote
  "#quotd #{`fortune -c -n 105 -s`.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')}"
end

#Twitter.configure { |c| puts c.to_yaml }
last_id = 1
#puts quote
#Twitter.update(quote)
while true
  timeline = Twitter.home_timeline( :since_id => last_id )

  unless timeline.empty?
    last_id = timeline[0].id
    request = []
    timeline.reverse.each do |st|
      requests = st.hashtags.select { |ht| ht.text == 'quotd' }
      unless request.empty?
        tweet = "@#{st.user.name} #{quote}"
        puts tweet
        Twitter.update tweet
      end
    end
  end
  sleep 300
  end

