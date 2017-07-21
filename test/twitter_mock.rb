module Twitter
  module REST
    class Config
      attr_accessor :consumer_key, :consumer_secret, :access_token, :access_token_secret
    end
    class Client
      def initialize
#        cnf = Struct.new("Config", :consumer_key, :consumer_secret, :access_token, :access_token_secret) {attr_accessor(:consumer_key, :consumer_secret, :access_token, :access_token_secret)}
        cnf = Config.new
        yield cnf
        puts "# -- Config begin ----------------"
        puts "# consumer_key: #{cnf.consumer_key}"
        puts "# consumer_secret: #{cnf.consumer_secret}"
        puts "# access_token: #{cnf.access_token}"
        puts "# access_token_secret: #{cnf.access_token_secret}"
        puts "#-- Config end -------------------"
      end
      
      def update(text)
        puts text
      end
    end
  end
end
 
