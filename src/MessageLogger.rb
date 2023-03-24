require_relative "./Database.rb"
require_relative "./Utils.rb"
require_relative "./Config.rb"

module MessageLogger
  @@bot = nil
  @@logchannels = {} # :server_id => channel_id
  @@logs = {} # :server_id => array<messages>

  def self.set(bot)
    @@bot = bot
  end

  def self.load_channels
    @@bot.servers.each { |key, value|
      logchannel = Database::ServerSettings.get_setting(key.to_s, "logchannel").to_s.to_i
      next if logchannel.zero?
      @@logchannels[key.to_s] = logchannel # id of the logchannel
    }
  end

  def self.add_channel(server_id, channel_id)
    @@logchannels[server_id.to_s] = channel_id.to_i
  end

  def self.log_message(server_id, data)
    # Hold up to 1000 messages for logging
    @@logs[server_id.to_s] ||= []
    @@logs[server_id.to_s].shift if @@logs[server_id.to_s].size >= 1000
    @@logs[server_id.to_s] << data
  end

  def self.edit_message(server_id, message_id, data)
    return if @@logchannels[server_id.to_s].nil?
    found = nil
    found ||= @@logs[server_id.to_s].find { |msg| msg[:id] == message_id }
    @@logs[server_id.to_s][@@logs[server_id.to_s].index(found)] = data if found
    return if found.nil?

    field_before = ""
    field_after = ""
    edit_event = ""
    link = ""

    lang = Utils.load_languages
    if lang[server_id.to_s] == "en"
      field_before = "Before"
      field_after = "After"
      edit_event = "Message Edited"
      link = "[Message link]"
    else
      field_before = "До"
      field_after = "После"
      edit_event = "Сообщение отредактировано"
      link = "[Ссылка на сообщение]"
    end

    embed = Discordrb::Webhooks::Embed.new()
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: data[:author].avatar_url, name: data[:author].username)
    embed.add_field(name: edit_event, value: "<##{data[:channel]}> -> #{link}(#{data[:link]})", inline: false)
    embed.add_field(name: field_before, value: found[:content], inline: true)
    embed.add_field(name: field_after, value: data[:content], inline: true)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment]) # Only before editing
    embed.color = Config::DEFAULT_EMBED_COLOR

    @@bot.send_message(@@logchannels[server_id.to_s], "", false, embed)
  end

  def self.delete_message(server_id, message_id)
    return if @@logchannels[server_id.to_s].nil?
    return if @@logs[server_id.to_s].nil?
    found = nil
    found ||= @@logs[server_id.to_s].find { |msg| msg[:id] == message_id }
    @@logs[server_id.to_s].delete(found) if found
    return if found.nil?

    delete_event = ""
    content = ""
    empty = ""

    lang = Utils.load_languages
    if lang[server_id.to_s] == "en"
      delete_event = "Message deleted"
      content = "Content"
      empty = "**[BOT]** *This message is either an embed/attachment or empty*"
    else
      delete_event = "Сообщение удалено"
      content = "Содержимое"
      empty = "**[БОТ]** *Это сообщение пустое или является вложением*"
    end

    embed = Discordrb::Webhooks::Embed.new()
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: found[:author].avatar_url, name: found[:author].username)
    embed.add_field(name: delete_event, value: "<##{found[:channel]}>", inline: false)
    embed.add_field(name: content, value: found[:content].empty? ? empty : found[:content], inline: false)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment]) # Only before editing
    embed.color = Config::DEFAULT_EMBED_COLOR

    @@bot.send_message(@@logchannels[server_id.to_s], "", false, embed)
  end
end
