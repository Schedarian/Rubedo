require_relative "../Utils.rb"

module Color
  include Utils

  def self.register_en(bot, server)
    bot.register_application_command(:color, "Gets color by random or by hex code", server_id: server) do |cmd|
      cmd.string(:hexcode, "Type in a color code, for example #D2323E. Leave field empty for random color")
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:color, "Получить цвет случайно или с помощью шестнадцатеричного кода", server_id: server) do |cmd|
      cmd.string(:hexcode, "Введите цветовой код, например #D2323E. Оставьте поле пустым для случайного цвета")
    end
  end

  def self.handle(bot)
    bot.application_command(:color) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      code = handler.options["hexcode"]
      code = code[1..-1] unless code.nil?
      code ||= "%06x" % (rand * 0xffffff)

      if code.length == 6 && code[/\H/] == nil
        color = code
        uri = URI("https://www.thecolorapi.com/id?hex=#{color}")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = color.to_i(16)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://singlecolorimage.com/get/#{color}/128x128")
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: json["name"]["value"])
        embed.description = "**HEX:** #{json["hex"]["value"]}\n**RGB:** #{json["rgb"]["value"][4..-2]}\n**CMYK:** #{json["cmyk"]["value"][5..-2]}"

        handler.respond(embeds: [] << embed)
      else
        if lang == "ru"
          handler.respond(content: "Цветовой код содержит ошибки")
        else
          handler.respond(content: "The color code is invalid")
        end
      end
    end
  end
end
