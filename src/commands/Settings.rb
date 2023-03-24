# Administrator only command
require_relative "../CommandHandler.rb"
require_relative "../Config.rb"
require_relative "../Database.rb"
require_relative "../Enums.rb"

register_settings = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:settings, "Manage server settings", server_id: server) { |cmd|
      cmd.subcommand(:show, "Show current server settings")
      cmd.subcommand(:reset, "Reset server settings")
    }
  else
    bot.register_application_command(:settings, "Управление настройками сервера", server_id: server) { |cmd|
      cmd.subcommand(:show, "Показать текущие настройки")
      cmd.subcommand(:reset, "Сбросить настройки")
    }
  end
}

CommandHandler.add_command(register_settings)

handle_settings = proc { |bot, language|
  bot.application_command(:settings).subcommand(:show) { |handler|
    begin
      handler.defer(ephemeral: false)
      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      logchannel = Database::ServerSettings.get_setting(handler.server_id, "logchannel").to_s.to_i
      starboardchannel = Database::ServerSettings.get_setting(handler.server_id, "starboardchannel").to_s.to_i
      starboardcount = Database::ServerSettings.get_setting(handler.server_id, "starboardcount").to_s.to_i

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        embed.description = "**Current server settings**"
        embed.add_field(name: "Permissions for /warnings", value: Enums::DISCORD_PERMISSIONS_EN[Database::ServerSettings.get_setting(handler.server_id, "warnperms")], inline: false)
        embed.add_field(name: "Permissions for /say and /embed", value: Enums::DISCORD_PERMISSIONS_EN[Database::ServerSettings.get_setting(handler.server_id, "embedperms")], inline: false)
        embed.add_field(name: "Message logging channel ID", value: logchannel.zero? ? "0 (Disabled)" : logchannel, inline: false)
        embed.add_field(name: "Starboard channel ID", value: starboardchannel.zero? ? "0 (Disabled)" : starboardchannel, inline: false)
        embed.add_field(name: "Starboard star count", value: starboardcount, inline: false)
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        embed.description = "**Текущие настройки сервера**"
        embed.add_field(name: "Права на использование /warnings", value: Enums::DISCORD_PERMISSIONS_RU[Database::ServerSettings.get_setting(handler.server_id, "warnperms")], inline: false)
        embed.add_field(name: "Права на использование /say, /embed", value: Enums::DISCORD_PERMISSIONS_RU[Database::ServerSettings.get_setting(handler.server_id, "embedperms")], inline: false)
        embed.add_field(name: "ID канала для логов", value: logchannel.zero? ? "0 (Disabled)" : logchannel, inline: false)
        embed.add_field(name: "ID канала для starboard", value: starboardchannel.zero? ? "0 (Disabled)" : starboardchannel, inline: false)
        embed.add_field(name: "Количество звёзд starboard", value: starboardcount, inline: false)
      end

      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }

  bot.application_command(:settings).subcommand(:reset) { |handler|
    begin
      handler.defer(ephemeral: false)

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Set server settings to default**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Настройки сервера сброшены**")
      end

      Database::ServerSettings.delete_settings(handler.server_id)
      Database::ServerSettings.create_defaults(handler.server_id)
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_settings)
