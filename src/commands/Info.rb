require_relative "../Enums.rb"
require_relative "../CommandHandler.rb"
require_relative "../Config.rb"

register_info = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:info, "Detailed information", server_id: server) { |cmd|
      cmd.subcommand(:user, "Info about a user") { |subcmd|
        subcmd.user(:username, "Choose a user", required: true)
      }

      cmd.subcommand(:server, "Info about the server")
    }
  else
    bot.register_application_command(:info, "Подробная информация", server_id: server) { |cmd|
      cmd.subcommand(:user, "Информация о пользователе") { |subcmd|
        subcmd.user(:username, "Выберите пользователя", required: true)
      }

      cmd.subcommand(:server, "Информация об этом сервере")
    }
  end
}

CommandHandler.add_command(register_info)

handle_info = proc { |bot, language|
  bot.application_command(:info).subcommand(:server) { |handler|
    server = bot.server(handler.server_id)
    embed = Discordrb::Webhooks::Embed.new
    embed.title = server.name
    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
    embed.color = Config::DEFAULT_EMBED_COLOR

    if language[handler.server_id.to_s] == "en"
      embed.description =
        "**ID:** #{server.id}\n" \
        "**Owner:** <@#{server.owner.id}>\n" \
        "**Creation date:** <t:#{server.creation_time.to_i}>\n" \
        "**Members:** #{server.member_count} (#{server.bot_members.size} bots)\n" \
        "**Channels:** #{server.channels.size}\n" \
        "**Roles:** #{server.roles.size}\n" \
        "**Emojis:** #{server.emoji.size}\n" \
        "**Boosts:** #{server.booster_count} (Level #{server.boost_level})\n" \
        "**Verification level:** #{Enums::DISCORD_VERIFICATION_LEVEL_EN[server.verification_level]}\n" \
        "**Content filtering:** #{Enums::DISCORD_CONTENT_FILTERS_EN[server.content_filter_level]}"
    else
      embed.description =
        "**ID:** #{server.id}\n" \
        "**Владелец:** <@#{server.owner.id}>\n" \
        "**Дата создания:** <t:#{server.creation_time.to_i}>\n" \
        "**Пользователей:** #{server.member_count} (Ботов: #{server.bot_members.size})\n" \
        "**Каналов:** #{server.channels.size}\n" \
        "**Ролей:** #{server.roles.size}\n" \
        "**Эмодзи:** #{server.emoji.size}\n" \
        "**Бустов:** #{server.booster_count} (Уровень #{server.boost_level})\n" \
        "**Уровень безопасности:** #{Enums::DISCORD_VERIFICATION_LEVEL_RU[server.verification_level]}\n" \
        "**Фильтрация контента:** #{Enums::DISCORD_CONTENT_FILTERS_RU[server.content_filter_level]}"
    end

    handler.respond(embeds: [embed])
  }

  bot.application_command(:info).subcommand(:user) { |handler|
    embed = Discordrb::Webhooks::Embed.new
    embed.color = Config::DEFAULT_EMBED_COLOR
    member = bot.member(handler.server_id, handler.options["username"])
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{member.name}##{member.discriminator}", icon_url: member.avatar_url)
    roles = ""

    member.roles.each do |role|
      next if role.name == "@everyone"
      roles = roles + "<@&#{role.id}> "
    end

    if language[handler.server_id.to_s] == "en"
      embed.add_field(name: "Basic info", value: "**ID:** #{member.id}\n" \
                      "**Bot account?** #{member.current_bot? == true ? "Yes" : "No"}\n" \
                      "**Status:** #{Enums::DISCORD_STATUS_EN[member.client_status.map { |k, v| v }.first]}\n" \
                      "**Account registered:** <t:#{member.creation_time.to_i}>", inline: true)
      embed.add_field(name: "Additional info", value: "**Nickname:** #{member.display_name}\n" \
                      "**Nitro booster?** #{member.boosting? == true ? "Yes" : "No"}\n" \
                      "**Joined the server:** <t:#{member.joined_at.to_i}>", inline: true)
      embed.add_field(name: "Roles [#{member.roles.size - 1}]", value: "#{roles == "" ? "[None]" : roles}", inline: false)
    else
      embed.add_field(name: "Основная информация", value: "**ID:** #{member.id}\n" \
                      "**Бот?** #{member.current_bot? == true ? "Да" : "Нет"}\n" \
                      "**Статус:** #{Enums::DISCORD_STATUS_RU[member.client_status.map { |k, v| v }.first]}\n" \
                      "**Аккаунт зарегистрирован:** <t:#{member.creation_time.to_i}>", inline: true)
      embed.add_field(name: "Дополнительная информация", value: "**Никнейм:** #{member.display_name}\n" \
                      "**Нитро бустер?** #{member.boosting? == true ? "Да" : "Нет"}\n" \
                      "**Присоединился к серверу:** <t:#{member.joined_at.to_i}>", inline: true)
      embed.add_field(name: "Роли [#{member.roles.size - 1}]", value: "#{roles == "" ? "[Отсутствуют]" : roles}", inline: false)
    end

    handler.respond(embeds: [embed])
  }
}

CommandHandler.add_handler(handle_info)
