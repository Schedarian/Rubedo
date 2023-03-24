require_relative "../CommandHandler.rb"
require_relative "../StarboardHandler.rb"
require_relative "../Config.rb"
require_relative "../Database.rb"

register_starboard = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:starboard, "Manage starboard, admin-only", server_id: server) { |cmd|
      cmd.subcommand(:setchannel, "Sets current channel as starboard channel")
      cmd.subcommand(:disable, "Sets starboard channel ID to 0")
      cmd.subcommand(:stars, "Sets min number of stars to get into the starboard channel") { |subcmd|
        subcmd.integer(:count, "Number of stars to get into the starboard channel", required: true)
      }
    }
  else
    bot.register_application_command(:starboard, "Управление starboard", server_id: server) { |cmd|
      cmd.subcommand(:setchannel, "Устанавливает данный канал как starboard")
      cmd.subcommand(:disable, "Устанавливает ID starboard канала равным 0")
      cmd.subcommand(:stars, "Устанавливает минимальное количество звёзд для попадания в канал") { |subcmd|
        subcmd.integer(:count, "Количество звёзд под сообщением для попадания в канал", required: true)
      }
    }
  end
}

CommandHandler.add_command(register_starboard)

handle_starboard = proc { |bot, language|
  bot.application_command(:starboard).subcommand(:setchannel) { |handler|
    begin
      handler.defer
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Starboard channel set to <##{handler.channel_id}>**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Канал starboard установлен на <##{handler.channel_id}>**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "starboardchannel", handler.channel_id.to_s)
      StarboardHandler.load_starboards
    rescue LocalJumpError;     end
  }

  bot.application_command(:starboard).subcommand(:disable) { |handler|
    begin
      handler.defer
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Starboard channel set to 0 (Disabled)**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Канал starboard установлен на 0 (Выключен)**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "starboardchannel", "0")
      StarboardHandler.load_starboards
    rescue LocalJumpError;     end
  }

  bot.application_command(:starboard).subcommand(:stars) { |handler|
    begin
      handler.defer
      starcount = handler.options["count"].to_i
      starcount = 1 if starcount < 1
      starcount = 100 if starcount > 100

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Starboard star count set to #{starcount}**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Количество звёзд для попадания в канал установлено на #{starcount}**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "starboardcount", "#{starcount}")
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_starboard)
