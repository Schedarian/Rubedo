require_relative "../Utils.rb"
require_relative "../Enums.rb"
require_relative "../Config.rb"

module Weather
  include Utils
  include Enums
  include Config

  WEATHER_TOKEN = Config.get_weather_token

  def self.register_en(bot, server)
    bot.register_application_command(:weather, "Shows current weather", server_id: server) do |cmd|
      cmd.string(:location, "Choose a location", required: true)
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:weather, "Погода на данный момент", server_id: server) do |cmd|
      cmd.string(:location, "Выберите место", required: true)
    end
  end

  def self.handle(bot)
    bot.application_command(:weather) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      data = `curl -s "https://api.openweathermap.org/data/2.5/weather?q=#{handler.options["location"].gsub(" ", "+")}&appid=#{WEATHER_TOKEN}"`
      json = data.to_s.empty? ? { "cod" => 404 } : JSON.parse(data)
      if json["cod"].to_s == "404"
        if lang == "ru"
          handler.respond(content: "Не удалось найти данные")
        else
          handler.respond(content: "Could not fetch data")
        end
      else
        time = Time.now - Time.now.utc_offset + json["timezone"]
        gmt = json["timezone"] > 0 ? "+" : ""
        time = "#{time.hour > 9 ? time.hour : "0" + time.hour.to_s}:#{time.min > 9 ? time.min : "0" + time.min.to_s}"

        embed = Discordrb::Webhooks::Embed.new
        embed.color = 13775422
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "http://openweathermap.org/img/wn/#{json["weather"][0]["icon"]}@2x.png")

        if lang == "ru"
          weather = Enums.get_weather_enum.key(json["weather"][0]["id"])
          embed.add_field(name: "Температура", value: (json["main"]["temp"].to_f - 273).to_i.to_s + " °C", inline: true)
          embed.add_field(name: "Погода", value: weather, inline: true)
          embed.add_field(name: "Влажность", value: json["main"]["humidity"].to_s + "%", inline: true)
          embed.add_field(name: "Ветер", value: json["wind"]["speed"].to_s + " м/c", inline: true)
          embed.add_field(name: "Давление", value: (json["main"]["pressure"].to_i * 0.75).to_s + " мм рт.ст.", inline: true)
          embed.add_field(name: "Часовой пояс", value: "#{json["name"]} GMT#{gmt}#{json["timezone"] / 3600} [#{time}]", inline: true)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Данные предоставлены OpenWeather API")
        else
          embed.add_field(name: "Temperature", value: (json["main"]["temp"].to_f - 273).to_i.to_s + " °C", inline: true)
          embed.add_field(name: "Weather", value: json["weather"][0]["description"].capitalize, inline: true)
          embed.add_field(name: "Humidity", value: json["main"]["humidity"].to_s + "%", inline: true)
          embed.add_field(name: "Wind", value: json["wind"]["speed"].to_s + " m/s", inline: true)
          embed.add_field(name: "Pressure", value: (json["main"]["pressure"].to_i * 0.75).to_s + " mm Hg", inline: true)
          embed.add_field(name: "Timezone", value: "#{json["name"]} GMT#{gmt}#{json["timezone"] / 3600} [#{time}]", inline: true)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Data provided by OpenWeather API")
        end

        handler.respond(embeds: [] << embed)
      end
    end
  end
end
