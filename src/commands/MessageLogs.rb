require_relative "../CommandHandler.rb"
require_relative "../Config.rb"
require_relative "../Database.rb"

register_messagelogs = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:messagelogs, "Manage message logging, admin-only", server_id: server) { |cmd|
      cmd.subcommand(:setchannel, "Sets current channel as logs channel")
      cmd.subcommand(:disable, "Sets logs channel ID to 0")
    }
  else
    bot.register_application_command(:messagelogs, "Управление starboard", server_id: server) { |cmd|
      cmd.subcommand(:setchannel, "Устанавливает данный канал для логов сообщений")
      cmd.subcommand(:disable, "Устанавливает ID канала для логов равным 0")
    }
  end
}

CommandHandler.add_command(register_messagelogs)

handle_messagelogs = proc { |bot, language|
  bot.application_command(:messagelogs).subcommand(:setchannel) { |handler|
    begin
      handler.defer
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Logging channel set to <##{handler.channel_id}>**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Канал для логов установлен на <##{handler.channel_id}>**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "logchannel", handler.channel_id.to_s)
      MessageLogger.load_channels
    rescue LocalJumpError;     end
  }

  bot.application_command(:messagelogs).subcommand(:disable) { |handler|
    begin
      handler.defer
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Logging channel set to 0 (Disabled)**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Канал для логов установлен на 0 (Выключен)**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "logchannel", "0")
      StarboardHandler.load_starboards
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_messagelogs)
