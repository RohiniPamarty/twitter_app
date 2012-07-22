require 'twitter_oauth'
require 'rubygems'
require 'yaml'
CONFIG_FILE = 'detail.yaml'
CONFIG = YAML::load(File.read(CONFIG_FILE))

consumer_key = CONFIG['oauth']['consumer_key']
consumer_secret = CONFIG['oauth']['consumer_secret']
request_token = CONFIG['oauth']['request_token']
request_secret = CONFIG['oauth']['request_secret']
read_till_id = nil


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
puts "Sucessfully signed in, please type commands for required outputs"
command = STDIN.readline.chomp
command = command.sub!(/ctc/, "")   
case command
 when ""
    if read_till_id
     timeline= client.home_timeline(options = {:count => 10, :since_id => read_till_id})
   
    else
    timeline = client.home_timeline(options= {:count => 10})
    end
#read_till_id = timeline.first.id unless timeline.empty?
    if timeline.empty?
     puts "No new tweets"
    else
    timeline = timeline.reverse 
    timeline.each{ |tweet|
        puts tweet['text'] + " @FROM #{tweet['user']['name']}"
        puts "\n"
    }
   end
when (command.scan(/\+/))
   command = command.sub!(/\+/,"")
   command= command.to_i
   timeline = client.home_timeline(options = {:count => 1, :max_id => command })
    timeline.each{ |tweet|
        puts tweet['text'] + " @FROM #{tweet['user']['name']}"
        puts "\n"
    }
 else
   client.update("#{command}")
   

end
