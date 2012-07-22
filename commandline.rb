require 'twitter_oauth'
require 'rubygems'
require 'yaml'
CONFIG_FILE = 'detail.yaml'
CONFIG = YAML::load(File.read(CONFIG_FILE))

consumer_key = CONFIG['oauth']['consumer_key']
consumer_secret = CONFIG['oauth']['consumer_secret']
request_token = CONFIG['oauth']['request_token']
request_secret = CONFIG['oauth']['request_secret']


if request_token.nil? and request_secret.nil?
  client = TwitterOAuth::Client.new(
       :consumer_key => consumer_key,
       :consumer_secret => consumer_secret
       )
  request_token = client.request_token

  puts "Please open the following address in your browser to authorize this application:"
  puts "#{request_token.authorize_url}\n"

  puts "Hit enter when you have completed authorization."
  STDIN.gets
  access_token = client.authorize(
      request_token.token,
      request_token.secret
  )

  File.open(CONFIG_FILE, 'w') do |out|
    CONFIG['oauth']['request_token'] = access_token.token
    CONFIG['oauth']['request_secret'] = access_token.secret
    YAML::dump(CONFIG, out)
  end
else
  client = TwitterOAuth::Client.new(
    :consumer_key => consumer_key,
    :consumer_secret => consumer_secret,
    :token => request_token,
    :secret => request_secret
  )
end

case ARGV[0]
 when "-l"
    timeline = client.home_timeline()
    timeline = timeline.reverse
    timeline.each{ |tweet|
        puts tweet['text'] + " @FROM #{tweet['user']['name']}"
        puts "\n"
    }
 when "-u"
    if ARGV[1].nil?
        puts "Please enter your status:"
        status = STDIN.readline.chomp
        client.update("#{status}")
    else
        client.update("#{ARGV[1]}")
    end
 when "-m"
    mentions = client.mentions()
    mentions = mentions.reverse
    mentions.each{ |tweet|
        puts tweet['text'] + " @FROM #{tweet['user']['name']}"
        puts "\n"
    }
end
