# Load some data like languages, commands, some loops

require_relative "./CommandHandler.rb"
require_relative "./EventsHandler.rb"
require_relative "./StarboardHandler.rb"
require_relative "./Database.rb"
require_relative "./Global.rb"
require_relative "./MessageLogger.rb"

require_relative "events/ReactionAdd.rb"
require_relative "events/MessageCreate.rb"
require_relative "events/MessageEdit.rb"
require_relative "events/MessageDelete.rb"
require_relative "events/ServerCreate.rb"
require_relative "events/ServerDelete.rb"
require_relative "events/Mention.rb"

require_relative "commands/8ball.rb"
require_relative "commands/About.rb"
require_relative "commands/Animals.rb"
require_relative "commands/Avatar.rb"
require_relative "commands/Coin.rb"
require_relative "commands/Color.rb"
require_relative "commands/Embed.rb"
require_relative "commands/Info.rb"
require_relative "commands/MessageLogs.rb"
require_relative "commands/Prune.rb"
require_relative "commands/Say.rb"
require_relative "commands/Settings.rb"
require_relative "commands/Starboard.rb"
require_relative "commands/Warnings.rb"
require_relative "commands/Weather.rb"

module Initializer
  @@users = 0

  def self.update_users(bot)
    users = 0
    bot.servers.each { |key, value|
      users += value.member_count
    }
    @@users = users
  end

  def self.get_users
    @@users
  end

  def self.run(bot)

    #Updates status every 30 seconds
    Thread.new {
      loop {
        time = Time.now - Time.now.utc_offset
        bot.watching = "#{time.hour > 9 ? time.hour : "0" + time.hour.to_s}:#{time.min > 9 ? time.min : "0" + time.min.to_s} UTC"
        sleep(30)
        self.update_users(bot)
        bot.watching = "#{@@users} users"
        sleep(30)
        bot.watching = "#{bot.servers.size} servers"
        sleep(30)
      }
    }

    Thread.new {
      # Initialize commands
      CommandHandler.set(bot)

      # Global first
      CommandHandler.register_global if Config::REGISTER_GLOBAL == true
      CommandHandler.handle_global

      # Server second
      CommandHandler.handle_commands
    }
    # Initialize events
    Thread.new {
      EventsHandler.set(bot)
      EventsHandler.handle_events
    }

    # Check databases
    Database.check_db(bot)

    # Initialize logger
    Thread.new {
      MessageLogger.set(bot)
      MessageLogger.load_channels
    }

    # Initialize starboard
    Thread.new {
      StarboardHandler.set(bot)
      StarboardHandler.load_starboards
    }

    # Add new tables to the existing databases
    # Necessary code here

  end
end
