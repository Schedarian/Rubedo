require_relative "../CommandHandler.rb"
require_relative "../Config.rb"

register_animals = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:animals, "Gets a random animal picture", server_id: server) { |cmd|
      cmd.string(:category, "Choose category", required: true, choices: { :dog => "dog", :cat => "cat" })
    }
  else
    bot.register_application_command(:animals, "Выдаёт картинку со случайным животным", server_id: server) { |cmd|
      cmd.string(:category, "Выберите категорию", required: true, choices: { :Dog => "dog", :Cat => "cat" })
    }
  end
}

CommandHandler.add_command(register_animals)

handle_animals = proc { |bot, language|
  bot.application_command(:animals) { |handler|
    category = handler.options["category"]
    embed = Discordrb::Webhooks::Embed.new
    embed.color = Config::DEFAULT_EMBED_COLOR

    if category == "dog"
      uri = URI("https://dog.ceo/api/breeds/image/random")
      response = Net::HTTP.get_response(uri)
      json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Woof!")
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: json["message"])
    else
      uri = URI("https://api.thecatapi.com/v1/images/search")
      response = Net::HTTP.get_response(uri)
      json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Meow!")
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: json[0]["url"])
    end

    handler.respond(embeds: [embed])
  }
}

CommandHandler.add_handler(handle_animals)
