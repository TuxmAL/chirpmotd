#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'twitter'

APP_CONF = YAML.load(File.open "#{Dir.pwd}/../config.config.yml"

Twitter.configure do |config|
  config.consumer_key = APP_CONF[:twitter][:consumer_key]
  config.consumer_secret = APP_CONF[:twitter][:consumer_secret]
  config.oauth_token = APP_CONF[:twitter][:oauth_token]
  config.oauth_token_secret = APP_CONF[:twitter][:oauth_token_secret]
end

#Twitter.configure { |c| puts c.to_yaml }
last_id = 1
quote = "#quotd #{`fortune -c -n 105 -s`.sub(/^\((.*)\)\s*$/, '[\\1]->').gsub(/[%\t\n\r]/, ' ').squeeze(' ')}"
#puts quote
Twitter.update(quote)
while false
  timeline = Twitter.user_timeline( :friends, :since_id => last_id )

  unless timeline.empty?
    last_id = timeline[0].id

    timeline.reverse.each do|st|
      puts "#{st.user.name} said #{st.text}"
    end

    sleep 300
  end
end
