require_relative "../CommandHandler.rb"
require_relative "../Initializer.rb"
require_relative "../Config.rb"

register_about = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:about, "Short info about this bot", server_id: server)
  else
    bot.register_application_command(:about, "Краткая информация об этом боте", server_id: server)
  end
}

CommandHandler.add_command(register_about)

handle_about = proc { |bot, language|
  START_TIME = Time.now.to_i
  bot.application_command(:about) { |handler|
    embed = Discordrb::Webhooks::Embed.new
    embed.title = bot.bot_user.distinct # Nickname + discriminator
    embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: bot.profile.avatar_url)
    embed.color = Config::DEFAULT_EMBED_COLOR
    time = Time.now - Time.now.utc_offset - START_TIME
    parsed_time = "[#{time.hour > 9 ? time.hour : "0" + time.hour.to_s}:#{time.min > 9 ? time.min : "0" + time.min.to_s}:#{time.sec > 9 ? time.sec : "0" + time.sec.to_s}]"

    if language[handler.server_id.to_s] == "en"
      embed.add_field(name: "Stats", value: "**Servers:** #{bot.servers.size}\n**Users:** #{Initializer.get_users}\n**Uptime (hh/mm/ss): #{parsed_time}**", inline: true)
      embed.add_field(name: "Useful links", value: "[Invite link](https://discord.com/api/oauth2/authorize?client_id=840665896556560435&permissions=0&scope=bot)\n[GitHub page](https://github.com/Schedarian/Rubedo)", inline: true)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Written using Discordrb library")
    else
      embed.add_field(name: "Статистика", value: "**Серверов:** #{bot.servers.size}\n**Пользователей:** #{Initializer.get_users}\n**Время работы (чч/мм/cc): #{parsed_time}** ", inline: true)
      embed.add_field(name: "Полезные ссылки", value: "[Пригласить](https://discord.com/api/oauth2/authorize?client_id=840665896556560435&permissions=0&scope=bot)\n[Страница на GitHub](https://github.com/Schedarian/Rubedo)", inline: true)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Написан с помощью библиотеки Discordrb")
    end

    handler.respond(embeds: [embed])
  }
}

CommandHandler.add_handler(handle_about)
