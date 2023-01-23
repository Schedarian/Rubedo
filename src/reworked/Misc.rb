module Commands
  def self.misc(bot)
    bot.command(:'8ball') do |event|
      response = ["It is certain",
                  "Without a doubt",
                  "You may rely on it",
                  "Yes definitely",
                  "It is decidedly so",
                  "As I see it, yes",
                  "Most likely",
                  "Yes",
                  "Outlook good",
                  "Signs point to yes",
                  "Reply hazy try again",
                  "Better not tell you now",
                  "Ask again later",
                  "Cannot predict now",
                  "Concentrate and ask again",
                  "Don't count on it",
                  "Outlook not so good",
                  "My sources say no",
                  "Very doubtful",
                  "My reply is no"]

      event.respond("***#{response.sample}***")
    end

    bot.command(:coin) do |event|
      event.respond("#{rand(0..1) == 1 ? ":coin: **Heads**" : ":coin: **Tails**"}")
    end

    bot.command(:avatar, min_args: 1, max_args: 1) do |event, *args|
      user = bot.user(proc do
        userId = event.message.mentions.first.nil? ? nil : event.message.mentions.first.id
        userId ||= args.first
      end.call)
      return "Provide correct `UserID`!" if user.nil?

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**Avatar of <@#{user.id}>**"
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: user.avatar_url)
      end
    end
  end
end
