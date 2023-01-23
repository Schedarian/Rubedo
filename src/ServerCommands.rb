require_relative "commands/About.rb"
require_relative "commands/Info.rb"
require_relative "commands/8ball.rb"
require_relative "commands/Avatar.rb"
require_relative "commands/Coin.rb"
require_relative "commands/Color.rb"
require_relative "commands/Animals.rb"
require_relative "commands/Voice.rb"
require_relative "commands/Weather.rb"
require_relative "commands/Warnings.rb"

module Commands
  def self.register_all_en(bot, server)
    Thread.new {
      About.register_en(bot, server)
      sleep(20)
      Info.register_en(bot, server)
      sleep(20)
      Eightball.register_en(bot, server)
      sleep(20)
      Avatar.register_en(bot, server)
      sleep(20)
      Coin.register_en(bot, server)
      sleep(20)
      Color.register_en(bot, server)
      sleep(20)
      Animals.register_en(bot, server)
      sleep(20)
      Voice.register_en(bot, server)
      sleep(20)
      Weather.register_en(bot, server)
      sleep(20)
      Warnings.register_en(bot, server)
    }
  end

  def self.register_all_ru(bot, server)
    Thread.new {
      About.register_ru(bot, server)
      sleep(20)
      Info.register_ru(bot, server)
      sleep(20)
      Eightball.register_ru(bot, server)
      sleep(20)
      Avatar.register_ru(bot, server)
      sleep(20)
      Coin.register_ru(bot, server)
      sleep(20)
      Color.register_ru(bot, server)
      sleep(20)
      Animals.register_ru(bot, server)
      sleep(20)
      Voice.register_ru(bot, server)
      sleep(20)
      Weather.register_ru(bot, server)
      sleep(20)
      Warnings.register_ru(bot, server)
    }
  end

  def self.update_en(bot, server)
    Warnings.register_en(bot, server)
    return true
  end

  def self.update_ru(bot, server)
    Warnings.register_ru(bot, server)
    return true
  end

  def self.handle_all(bot, caldera)
    About.handle(bot)
    Info.handle(bot)
    Eightball.handle(bot)
    Avatar.handle(bot)
    Coin.handle(bot)
    Color.handle(bot)
    Animals.handle(bot)
    Voice.handle(bot, caldera)
    Weather.handle(bot)
    Warnings.handle(bot)
  end

  def self.remove_all(bot, server)
    Thread.new {
      commands = bot.get_application_commands(server_id: server)
      commands.each { |cmd| sleep(5); bot.delete_application_command(cmd.id, server_id: server) }
    }
  end
end
