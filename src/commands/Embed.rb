require_relative "../CommandHandler.rb"
require_relative "../Utils.rb"

register_embed = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:embed, "Send an embed from bot", server_id: server) { |cmd|
      cmd.subcommand(:build, "Build and embed") { |subcmd|
        subcmd.string(:json, "Embed in json form", required: true)
      }
      cmd.subcommand(:permissions, "Change permissions for this command, admin-only command") { |subcmd|
        subcmd.string(:permission, "Choose permission for /embed and /say commands", required: true, choices: { :"Administrator" => :administrator,
                                                                                                                :"Ban members" => :ban_members,
                                                                                                                :"Kick members" => :kick_members,
                                                                                                                :"Manage server" => :manage_server,
                                                                                                                :"Manage channels" => :manage_channels,
                                                                                                                :"Manage messages" => :manage_messages })
      }
    }
  else
    bot.register_application_command(:embed, "Отправить вложение от имени бота", server_id: server) { |cmd|
      cmd.subcommand(:build, "Создать вложение") { |subcmd|
        subcmd.string(:json, "Вложение в формате json", required: true)
      }
      cmd.subcommand(:permissions, "Изменить права на данную команду, только для администраторов") { |subcmd|
        subcmd.string(:permission, "Выберите уровень доступа к командам этой категории", required: true, choices: { :"Администратор" => :administrator,
                                                                                                                    :"Бан пользователей" => :ban_members,
                                                                                                                    :"Кик пользователей" => :kick_members,
                                                                                                                    :"Управление сервером" => :manage_server,
                                                                                                                    :"Управление каналами" => :manage_channels,
                                                                                                                    :"Управление сообщениями" => :manage_messages })
      }
    }
  end
}

CommandHandler.add_command(register_embed)

handle_embed = proc { |bot, language|
  bot.application_command(:embed).subcommand(:build) { |handler|
    begin
      handler.defer

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "embedperms")) == false
        (handler.send_message(content: "**The json string you provided is not valid**"); return) if Utils.valid_json?(handler.options["json"]).nil?
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "embedperms")) == false
        (handler.send_message(content: "**Строка json введена некорректно**"); return) if Utils.valid_json?(handler.options["json"]).nil?
      end

      json = JSON.parse(handler.options["json"])

      begin
        handler.channel.send_embed { |embed|
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(json["author"]["name"], json["author"]["url"], json["author"]["icon_url"]) unless json["author"].nil?
          embed.title = json["title"] unless json["title"].nil?
          embed.color = json["color"][1..-1].to_i(16) unless json["color"].nil?
          embed.description = json["description"]
          embed.url = json["url"] unless json["url"].nil?
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: json["thumbnail"]["url"]) unless json["thumbnail"].nil?
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: json["image"]["url"]) unless json["image"].nil?
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: json["footer"]["text"], icon_url: json["footer"]["icon_url"]) unless json["footer"].nil?
          embed.timestamp = Time.at(json["timestamp"].to_i, in: "+00:00") unless json["timestamp"].nil?
          json["fields"].each { |field|
            embed.add_field(name: field["name"], value: field["value"], inline: field["inline"])
          } unless json["fields"].nil?
        }
        handler.send_message(content: "**Created embed successfully**") if language[handler.server_id.to_s] == "en"
        handler.send_message(content: "**Вложение успешно создано**") if language[handler.server_id.to_s] == "ru"
      rescue Discordrb::Errors::InvalidFormBody, ArgumentError => e
        handler.send_message(content: "**Invalid embed parameters**") if language[handler.server_id.to_s] == "en"
        handler.send_message(content: "**Некорректно заданные параметры**") if language[handler.server_id.to_s] == "ru"
      rescue Discordrb::Errors::NoPermission
        handler.send_message(content: "**I'm not allowed to send messages in this channel**") if language[handler.server_id.to_s] == "en"
        handler.send_message(content: "**У меня нет прав отправлять сообщения в данный канал**") if language[handler.server_id.to_s] == "ru"
      end
    rescue LocalJumpError;     end
  }

  bot.application_command(:embed).subcommand(:permissions) { |handler|
    begin
      handler.defer(ephemeral: false)
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Set `/embed & /say` permissions to #{handler.options["permission"]}**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Установлены права на использование `/embed & /say`: #{Enums::DISCORD_PERMISSIONS_RU[handler.options["permission"].to_sym]}**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "embedperms", handler.options["permission"])
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_embed)
