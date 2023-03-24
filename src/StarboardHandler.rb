require_relative "./EventsHandler.rb"
require_relative "./Database.rb"
require_relative "./Config.rb"
require_relative "events/ReactionAdd.rb"

module StarboardHandler
  @@bot = nil
  @@servers = {} # :serverid => array<message>

  def self.set(bot)
    @@bot = bot
  end

  def self.add_message(serverid, message)
    @@servers[serverid.to_s].shift if @@servers[serverid.to_s].size >= 100
    @@servers[serverid.to_s] << message
  end

  def self.add_server(severid)
    @@servers[serverid.to_s] = []
  end

  # On startup and after settings are changed
  def self.load_starboards
    @@bot.servers.each { |key, value|
      @@servers[key.to_s] = []
      sbchannel = Database::ServerSettings.get_setting(key.to_s, "starboardchannel").to_s.to_i
      # Skip if channel is off
      next if sbchannel.zero?
      # Find bot's messages with footer id
      @@servers[key.to_s] = @@bot.channel(sbchannel, key).history(100).filter { |message| !message&.embeds&.first&.footer.nil? }
    }
  end

  def self.star_added(event)
    # Return if:
    # 1. The message length is greater than 1000
    # 2. The message reaction count is lower than settings value
    # 3. If Starboard is disabled
    # 4. Reaction count is lower than on cached message
    return if event.message.content.size > 1000
    reactions = event.message.reactions.find { |r| r.name == "⭐" }
    return if reactions.count < Database::ServerSettings.get_setting(event.server.id.to_s, "starboardcount").to_s.to_i
    return if Database::ServerSettings.get_setting(event.server.id.to_s, "starboardchannel").to_s.to_i.zero?
    found = @@servers[event.server.id.to_s].find { |e| e.embeds.first.footer.text[4..-1] == event.message.id.to_s }

    lang = Utils.load_languages
    jump = ""
    fieldname = ""

    if lang[event.server.id.to_s] == "en"
      jump = "[Jump to message]"
      fieldname = "Content"
      link = "[Link]"
    else
      jump = "[К сообщению]"
      fieldname = "Содержимое"
      link = "[Ссылка]"
    end

    sleep(1)

    unless found.nil?
      # Edit message embed (star count)
      return if reactions.count <= found.embeds.first.description[0..20].tr("^0-9", "").to_i
      old_embed = found.embeds.first
      new_embed = Discordrb::Webhooks::Embed.new
      new_embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: old_embed.author.name, icon_url: old_embed.author.icon_url)
      new_embed.color = old_embed.color
      new_embed.description = "**#{reactions.count}** ⭐ **#{jump}(#{event.message.link})**"
      new_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: old_embed.footer.text)
      new_embed.image = Discordrb::Webhooks::EmbedImage.new(url: old_embed.image.url) unless old_embed.image.nil?
      new_embed.add_field(name: old_embed.fields.first.name, value: old_embed.fields.first.value, inline: false)

      found.edit("", new_embed)
    else

      # Add message to starboard channel
      embed_value = event.message.content
      embed_value += "\n#{event.message.attachments&.first&.url}"

      msg = @@bot.channel(Database::ServerSettings.get_setting(event.server.id.to_s, "starboardchannel").to_s.to_i, event.server.id).send_embed { |embed|
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.author.name, icon_url: event.message.author.avatar_url)
        embed.description = "**#{reactions.count}** ⭐ **#{jump}(#{event.message.link})**"
        embed.add_field(name: fieldname, value: embed_value, inline: false)
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: event.message.attachments&.first&.url)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "ID: #{event.message.id.to_s}")
        embed.color = Config::DEFAULT_EMBED_COLOR
      }
      # Add message with embed to array
      self.add_message(event.server.id, msg)
    end
  end
end
