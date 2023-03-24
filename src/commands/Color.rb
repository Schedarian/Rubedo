require_relative "../CommandHandler.rb"

register_color = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:color, "Gets color by random or by hex code", server_id: server) { |cmd|
      cmd.string(:hexcode, "Type in a color code, for example #D2323E. Leave field empty for random color")
    }
  else
    bot.register_application_command(:color, "Получить цвет случайно или с помощью шестнадцатеричного кода", server_id: server) { |cmd|
      cmd.string(:hexcode, "Введите цветовой код, например #D2323E. Оставьте поле пустым для случайного цвета")
    }
  end
}

CommandHandler.add_command(register_color)

handle_color = proc { |bot, language|
  bot.application_command(:color) { |handler|
    begin
      handler.defer(ephemeral: false)
      # This is some black magic, guess it works
      code = handler.options["hexcode"] # Get option
      code = code[1..-1] if code # Parse code if it exists
      code ||= "%06x" % (rand * 0xffffff) # And if code is nil, generate a random one

      if code.length == 6 && code[/\H/] == nil
        uri = URI("https://www.thecolorapi.com/id?hex=#{code}")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = code.to_i(16)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://singlecolorimage.com/get/#{code}/128x128")
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: json["name"]["value"])
        embed.description = "**HEX:** #{json["hex"]["value"]}\n**RGB:** #{json["rgb"]["value"][4..-2]}\n**CMYK:** #{json["cmyk"]["value"][5..-2]}"
      else
        if language[handler.server_id.to_s] == "en"
          handler.send_message(content: "**The color code is invalid**")
        else
          handler.send_message(content: "**Цветовой код содержит ошибки**")
        end
        return
      end

      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_color)
