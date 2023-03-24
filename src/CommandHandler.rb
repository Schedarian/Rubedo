require_relative "./Utils.rb"

module CommandHandler
  @@bot = nil
  @@languages = Utils.load_languages # Hash server => language, initializes from json at startup
  @@commands = [] # List of commands as lambdas for easier bulk registration
  @@handlers = [] # List of handlers as lambdas for easier bulk handling

  @@global_commands = []
  @@global_handlers = []

  def self.set(bot)
    @@bot = bot
  end

  def self.add_command(command)
    @@commands << command
  end

  def self.add_handler(handler)
    @@handlers << handler
  end

  def self.add_global_command(command)
    @@global_commands << command
  end

  def self.add_global_handler(handler)
    @@global_handlers << handler
  end

  def self.register_global
    Thread.new {
      @@global_commands.each { |cmd|
        cmd.call(@@bot)
      }
    }
  end

  def self.handle_global
    @@global_handlers.each { |handler|
      handler.call(@@bot)
    }
  end

  def self.register_commands(server, language)
    @@languages[server] = language
    Utils.update_languages(@@languages)

    Thread.new {
      @@commands.each { |cmd|
        cmd.call(@@bot, server, language)
        sleep(20) # This is needed to avoid rate limiting
      }
    }
  end

  # Some commands use rescue LocalJumpError, because I'm tired of infinite nested ifs
  def self.handle_commands
    @@handlers.each { |handler|
      handler.call(@@bot, @@languages)
    }
  end

  def self.delete_commands(server)
    Thread.new {
      commands = @@bot.get_application_commands(server_id: server) # Assigning to variable cause getting commands takes some time
      commands.each { |cmd|
        @@bot.delete_application_command(cmd.id, server_id: server)
        sleep(20)
      }
    }
  end
end
