require 'cinch'

GREETINGS_INPUT_REGEXP = /((h|H)i|(s|S)alut|(c|C)oucou|(h|H)ello|(y|Y)ellow|(P|p)lop|(B|b)onjour)(.*?)/
GREETINGS_OUTPUT = %w(Hello! Bonjour Salutations Hey! Yo Yop Bello!)
provlux-irc-bot
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

  on :message, /(.*?)shokobon(s)(.*?)/ do |m|
    m.reply "Hmmm... J'aime les shokobons"
  end
end

bot.start