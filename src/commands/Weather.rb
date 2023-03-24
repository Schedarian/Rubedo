require_relative "../CommandHandler.rb"
require_relative "../Enums.rb"
require_relative "../Config.rb"

register_weather = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:weather, "Shows current weather", server_id: server) { |cmd|
      cmd.string(:location, "Choose a location", required: true)
    }
  else
    bot.register_application_command(:weather, "Погода на данный момент", server_id: server) { |cmd|
      cmd.string(:location, "Выберите место", required: true)
    }
  end
}

CommandHandler.add_command(register_weather)

handle_weather = proc { |bot, language|
  bot.application_command(:weather) { |handler|
    handler.defer(ephemeral: false)
    #I use curl to get the data because stdlib doesn't support non-ascii characters since ruby 3.0 I think... (allegedly unsafe code)
    data = `curl -s "https://api.openweathermap.org/data/2.5/weather?q=#{handler.options["location"].gsub(" ", "+")}&appid=#{Config::WEATHER_TOKEN}"`
    json = data.to_s.empty? ? { "cod" => 404 } : JSON.parse(data) # set it to 404 because easier to work with
    embed = Discordrb::Webhooks::Embed.new
    embed.color = Config::DEFAULT_EMBED_COLOR

    add_weather = proc { |lang|
      sign = json["timezone"] > 0 ? "+" : "" # Add plus sign if timezone is positive, minus is added automatically if needed
      time = Time.now - Time.now.utc_offset + json["timezone"]
      time = "#{time.hour > 9 ? time.hour : "0" + time.hour.to_s}:#{time.min > 9 ? time.min : "0" + time.min.to_s}" # Some fancy interpolation so time looks nice
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "http://openweathermap.org/img/wn/#{json["weather"][0]["icon"]}@2x.png")

      if lang == "en"
        embed.add_field(name: "Temperature", value: (json["main"]["temp"].to_f - 273).to_i.to_s + " °C", inline: true)
        embed.add_field(name: "Weather", value: json["weather"][0]["description"].capitalize, inline: true)
        embed.add_field(name: "Humidity", value: json["main"]["humidity"].to_s + "%", inline: true)
        embed.add_field(name: "Wind", value: json["wind"]["speed"].to_s + " m/s", inline: true)
        embed.add_field(name: "Pressure", value: (json["main"]["pressure"].to_i * 0.75).to_s + " mm Hg", inline: true)
        embed.add_field(name: "Timezone", value: "#{json["name"]} GMT#{sign}#{json["timezone"] / 3600} [#{time}]", inline: true)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Data provided by OpenWeather API")
      else
        weather = Enums::WEATHER_RU.key(json["weather"][0]["id"])
        embed.add_field(name: "Температура", value: (json["main"]["temp"].to_f - 273).to_i.to_s + " °C", inline: true)
        embed.add_field(name: "Погода", value: weather, inline: true)
        embed.add_field(name: "Влажность", value: json["main"]["humidity"].to_s + "%", inline: true)
        embed.add_field(name: "Ветер", value: json["wind"]["speed"].to_s + " м/c", inline: true)
        embed.add_field(name: "Давление", value: (json["main"]["pressure"].to_i * 0.75).to_s + " мм рт.ст.", inline: true)
        embed.add_field(name: "Часовой пояс", value: "#{json["name"]} GMT#{sign}#{json["timezone"] / 3600} [#{time}]", inline: true)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Данные предоставлены OpenWeather API")
      end
    }

    begin
      if language[handler.server_id.to_s] == "en"
        json["cod"].to_s == "404" ? (handler.send_message(content: "**Could not fetch data**"); return) : (add_weather.call("en"); handler.send_message(embeds: [embed]))
      else
        json["cod"].to_s == "404" ? (handler.send_message(content: "**Не удалось найти данные**"); return) : (add_weather.call("ru"); handler.send_message(embeds: [embed]))
      end
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_weather)
