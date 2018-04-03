require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'cgi'

GREETINGS_INPUT_REGEXP = /(hi|salut|coucou|hello|yellow|plop|bonjour)(.*?)/i
GREETINGS_OUTPUT = %w(Hello! Bonjour Salutations Hey! Yo Yop Bello!)

def get_weather(area)
  url       = "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=#{CGI.escape(area)}"
  document  = Nokogiri::XML(open(url))
  
  qualitive = document.css('fcttext')
  
  document.css("simpleforecast forecastday").each_with_index do |forecastday, i|
    highs = forecastday.css('high')
    lows  = forecastday.css('low')
    
    "\n"
    + forecastday.css("date weekday").first.content
    + "\n"
    + " High: #{highs.css('celsius').first.content} C \n"
    + " Low:  #{lows.css('celsius').first.content} C   \n"
    + " #{qualitive[i].content} \n" if qualitive[i]
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = ENV['BOT_NAME'] # Le nom du bot
    c.realname = "Marcassin Sanglier" # Le nom réel du bot
    c.delay_joins = 5 # Un temps d'attente avant de rejoindre un chan
    c.messages_per_second = 1.0 # messages par seconde,  pour éviter de se faire kick pour flood
    c.server_queue_size = 1 # Un message par cible pour du round robin, évite de se faire kick
    c.server = "irc.freenode.org"
    c.channels = ["#provlux"]
    c.sasl.username = ENV['BOT_NAME']
    c.sasl.password = ENV['BOT_PASSWORD']
  end

  on :message, GREETINGS_INPUT_REGEXP do |m|
    m.reply GREETINGS_OUTPUT.sample
  end

  on :message, 'ping' do |m|
    m.reply 'pong'
  end

  on :message, 'pong' do |m|
    m.reply 'ping'
  end

  on :message, /#{ENV['BOT_NAME']}( )?(\?)?/ do |m|
    m.reply 'Oui?'
  end

  on :message, 'Quelle heure est-il?' do |m|
    m.reply "Il est très exactement #{Time.now.to_s}"
  end

  on :message, /(.*?)(shokobon|cookie|bonbon)(s)?(.*?)?/ do |m, _, sweet_name|
    m.reply "Hmmm... J'aime les #{sweet_name}s"
  end

  on :message, /^Je suis (\S+)$/i do |m, dad_joke_surname|
    m.reply "Bonjour #{dad_joke_surname}, je suis #{ENV['BOT_NAME']}"
  end

  on :message, /^!meteo (.*)+/, do |m, area|
    forecast = get_weather(area)
    m.reply forecast
  end
end

bot.start