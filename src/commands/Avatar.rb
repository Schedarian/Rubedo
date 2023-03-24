require_relative "../CommandHandler.rb"
require_relative "../Config.rb"

register_avatar = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:avatar, "Gets user profile picture", server_id: server) { |cmd|
      cmd.user(:username, "Choose a user", required: true)
    }
  else
    bot.register_application_command(:avatar, "Получить картинку профиля пользователя", server_id: server) { |cmd|
      cmd.user(:username, "Выберите пользователя", required: true)
    }
  end
}

CommandHandler.add_command(register_avatar)

handle_avatar = proc { |bot, language|
  bot.application_command(:avatar) { |handler|
    user = bot.user(handler.options["username"])
    embed = Discordrb::Webhooks::Embed.new
    embed.color = Config::DEFAULT_EMBED_COLOR
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: user.avatar_url)

    if language[handler.server_id.to_s] == "en"
      embed.description = "**#{user.mention}'s profile picture**"
    else
      embed.description = "**Аватар пользователя #{user.mention}**"
    end

    handler.respond(embeds: [embed])
  }
}

CommandHandler.add_handler(handle_avatar)
