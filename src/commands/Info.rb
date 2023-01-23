require_relative "../Utils.rb"

module Info
  include Utils

  def self.register_en(bot, server)
    bot.register_application_command(:info, "Detailed information", server_id: server) do |cmd|
      cmd.subcommand(:user, "Info about a user") do |subcmd|
        subcmd.user(:username, "Choose a user", required: true)
      end

      cmd.subcommand(:server, "Info about the server")
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:info, "Подробная информация", server_id: server) do |cmd|
      cmd.subcommand(:user, "Информация о пользователе") do |subcmd|
        subcmd.user(:username, "Выберите пользователя", required: true)
      end

      cmd.subcommand(:server, "Информация об этом сервере")
    end
  end

  def self.handle(bot)
    bot.application_command(:info).subcommand(:server) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      server = bot.server(handler.server_id)

      embed = Discordrb::Webhooks::Embed.new
      embed.title = server.name
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
      embed.color = 13775422

      if lang == "ru"
        embed.description = "**ID:** #{server.id}\n**Владелец:** <@#{server.owner.id}>\n**Дата создания:** <t:#{server.creation_time.to_i}>\n**Пользователей:** #{server.member_count} (Ботов: #{server.bot_members.size})\n**Каналов:** #{server.channels.size}\n**Ролей:** #{server.roles.size}\n**Эмодзи:** #{server.emoji.size}\n**Бустов:** #{server.booster_count} (Уровень #{server.boost_level})\n**Уровень безопасности:** #{Utils.parse_verification_level(server.verification_level, lang)}\n**Фильтрация контента:** #{Utils.parse_content_filtering(server.content_filter_level, lang)}"
      else
        embed.description = "**ID:** #{server.id}\n**Owner:** <@#{server.owner.id}>\n**Creation date:** <t:#{server.creation_time.to_i}>\n**Members:** #{server.member_count} (#{server.bot_members.size} bots)\n**Channels:** #{server.channels.size}\n**Roles:** #{server.roles.size}\n**Emojis:** #{server.emoji.size}\n**Boosts:** #{server.booster_count} (Level #{server.boost_level})\n**Verification level:** #{Utils.parse_verification_level(server.verification_level, lang)}\n**Content filtering:** #{Utils.parse_content_filtering(server.content_filter_level, lang)}"
      end

      handler.respond(embeds: [] << embed)
    end

    bot.application_command(:info).subcommand(:user) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      user = bot.user(handler.options["username"])
      member = bot.member(handler.server_id, user.id)

      roles = ""
      member.roles.each do |role|
        next if role.name == "@everyone"
        roles = roles + "<@&#{role.id}> "
      end

      embed = Discordrb::Webhooks::Embed.new
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{user.name}##{user.discriminator}", icon_url: user.avatar_url)
      embed.color = 13775422

      if lang == "ru"
        embed.add_field(name: "Основная информация", value: "**ID:** #{user.id}\n**Бот?** #{user.current_bot? == true ? "Да" : "Нет"}\n**Статус:** #{Utils.parse_status(user.status, lang)}\n**Аккаунт зарегистрирован:** <t:#{user.creation_time.to_i}>", inline: true)
        embed.add_field(name: "Дополнительная информация", value: "**Никнейм:** #{member.display_name}\n**Нитро бустер?** #{member.boosting? == true ? "Да" : "Нет"}\n**Присоединился к серверу:** <t:#{member.joined_at.to_i}>", inline: true)
        embed.add_field(name: "Роли [#{member.roles.size - 1}]", value: "#{roles == "" ? "[Отсутствуют]" : roles}", inline: false)
      else
        embed.add_field(name: "Basic info", value: "**ID:** #{user.id}\n**Bot account?** #{user.current_bot? == true ? "Yes" : "No"}\n**Status:** #{Utils.parse_status(user.client_status, lang)}\n**Account registered:** <t:#{user.creation_time.to_i}>", inline: true)
        embed.add_field(name: "Additional info", value: "**Nickname:** #{member.display_name}\n**Nitro booster?** #{member.boosting? == true ? "Yes" : "No"}\n**Joined the server:** <t:#{member.joined_at.to_i}>", inline: true)
        embed.add_field(name: "Roles [#{member.roles.size - 1}]", value: "#{roles == "" ? "[None]" : roles}", inline: false)
      end

      handler.respond(embeds: [] << embed)
    end
  end
end
