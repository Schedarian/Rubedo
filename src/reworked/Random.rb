module Commands
  def self.random(bot)
    bot.command(:random, min_args: 1, max_args: 1) do |event, *args|
      case (args.first)

      when "colour", "color"
        colour = "%06x" % (rand * 0xffffff)
        uri = URI("https://www.thecolorapi.com/id?hex=#{colour}")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        event.send_embed do |embed|
          embed.color = 3092790
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://singlecolorimage.com/get/#{colour}/128x128")
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: json["name"]["value"])
          embed.description = "**Hex value:** #{json["hex"]["value"]}\n**RGB:** #{json["rgb"]["value"][4..-2]}\n**CMYK:** #{json["cmyk"]["value"][5..-2]}"
        end
      when "dog"
        uri = URI("https://dog.ceo/api/breeds/image/random")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        event.send_embed do |embed|
          embed.color = 3092790
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Woof!")
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: json["message"])
        end
      when "cat"
        uri = URI("https://api.thecatapi.com/v1/images/search")
        response = Net::HTTP.get_response(uri)
        json = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        event.send_embed do |embed|
          embed.color = 3092790
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Meow!")
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: json[0]["url"])
        end
      when "pasta", "copypasta"
        begin
          data = `curl -L -A 'ruby' https://www.reddit.com/r/copypasta/random.json?limit=1`
          text = JSON.parse(data)[0]["data"]["children"][0]["data"]["selftext"]
          event.send_embed do |embed|
            embed.title = ":warning: Possible NSFW content"
            embed.description = "||#{text}||"
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "r/copypasta")
            embed.color = 3092790
          end
        rescue
          event.respond("Something went wrong, try again")
        end
      end
    end
  end
end
