require_relative "../Utils.rb"

module Animals
  def self.register_en(bot, server)
    bot.register_application_command(:animals, "Gets a random animal picture", server_id: server) do |cmd|
      cmd.string(:category, "Choose category", required: true, choices: { :dog => "dog", :cat => "cat" })
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:animals, "Выдаёт картинку со случайным животным", server_id: server) do |cmd|
      cmd.string(:category, "Выберите категорию", required: true, choices: { :dog => "dog", :cat => "cat" })
    end
  end

  def self.handle(bot)
    bot.application_command(:animals) do |handler|
      category = handler.options["category"]
      embed = Discordrb::Webhooks::Embed.new
      embed.color = 13775422
      if category == "dog"
        uri = URI("https://dog.ceo/api/breeds/image/random")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Woof!")
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: json["message"])

        handler.respond(embeds: [] << embed)
      else
        uri = URI("https://api.thecatapi.com/v1/images/search")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Meow!")
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: json[0]["url"])

        handler.respond(embeds: [] << embed)
      end
    end
  end
end
