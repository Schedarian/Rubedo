require_relative "../Utils.rb"

module About
  include Utils

  START_TIME = Time.now

  def self.register_en(bot, server)
    bot.register_application_command(:about, "Short info about this bot", server_id: server)
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:about, "Краткая информация об этом боте", server_id: server)
  end

  def self.handle(bot)
    bot.application_command(:about) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      embed = Discordrb::Webhooks::Embed.new
      embed.title = "Rubedo#6983"
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: bot.profile.avatar_url)
      embed.color = 13775422

      if lang == "ru"
        embed.add_field(name: "Статистика", value: "**Серверов:** #{bot.servers.size}\n**Пользователей:** #{$users}\n**Время работы:** #{(Time.now - START_TIME).to_i / 3600} часов", inline: true)
        embed.add_field(name: "Полезные ссылки", value: "[Пригласить](https://discord.com/api/oauth2/authorize?client_id=840665896556560435&permissions=0&scope=bot)", inline: true)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Написан с помощью библиотеки Discordrb")
      else
        embed.add_field(name: "Stats", value: "**Servers:** #{bot.servers.size}\n**Users:** #{$users}\n**Uptime:** #{(Time.now - START_TIME).to_i / 3600} hours", inline: true)
        embed.add_field(name: "Useful links", value: "[Invite link](https://discord.com/api/oauth2/authorize?client_id=840665896556560435&permissions=0&scope=bot)", inline: true)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Written using Discordrb library")
      end

      handler.respond(embeds: [] << embed)
    end
  end
end
