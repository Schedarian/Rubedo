require_relative "../Utils.rb"

module Avatar
  include Utils

  def self.register_en(bot, server)
    bot.register_application_command(:avatar, "Gets user profile picture", server_id: server) do |cmd|
      cmd.user(:username, "Choose a user", required: true)
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:avatar, "Получить картинку профиля пользователя", server_id: server) do |cmd|
      cmd.user(:username, "Выберите пользователя", required: true)
    end
  end

  def self.handle(bot)
    bot.application_command(:avatar) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      user = bot.user(handler.options["username"])

      embed = Discordrb::Webhooks::Embed.new
      embed.color = 13775422
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: user.avatar_url)

      if lang == "ru"
        embed.description = "**Аватар пользователя <@#{user.id}>**"
      else
        embed.description = "**Avatar of <@#{user.id}>**"
      end

      handler.respond(embeds: [] << embed)
    end
  end
end
