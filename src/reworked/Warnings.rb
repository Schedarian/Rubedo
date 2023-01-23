module Commands
  def self.warnings(bot)
    bot.command(:warn, min_args: 1) do |event, *args|
      return if event.server.nil?
      return "Insufficient user permissions" unless event.author.permission?(:ban_members)
      user = bot.member(event.server.id, proc do
        userId = event.message.mentions.first.nil? ? nil : event.message.mentions.first.id
        userId ||= args.first
      end.call)
      return "Provide correct `UserID`!" if user.nil?
      return "Reason must be `<256` symbols!" if args[1..-1].join(" ").length > 256
      reason = "[No reason provided]" if args.size == 1
      reason ||= args[1..-1].join(" ")

      dataDir = "data/servers/#{event.server.id}"
      FileUtils.mkdir_p(dataDir) unless Dir.exist?(dataDir)
      File.new("#{dataDir}/warnings.json", "w").puts("{}") unless File.exist?("#{dataDir}/warnings.json")

      newWarn = {
        :reason => reason,
        :issuedBy => event.author.id,
        :timestamp => Time.now.to_i,
      }

      warnData = JSON.parse(File.read("#{dataDir}/warnings.json"))
      warnData[user.id.to_s] = [] if warnData[user.id.to_s].nil?
      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**User <@#{user.id}> has reached the limit of `10 warnings`!**"
      end && return if warnData[user.id.to_s].size > 9

      warnData[user.id.to_s] << newWarn
      File.write("#{dataDir}/warnings.json", warnData.to_json)

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**User <@#{user.id}> has been warned | This is case `№#{warnData[user.id.to_s].size}`**"
        embed.add_field(name: "Reason", value: "`#{reason}`", inline: false)
      end
    end

    bot.command(:unwarn, min_args: 1, max_args: 2) do |event, *args|
      return if event.server.nil?
      return unless event.author.permission?(:ban_members)
      user = bot.member(event.server.id, proc do
        userId = event.message.mentions.first.nil? ? nil : event.message.mentions.first.id
        userId ||= args.first
      end.call)
      return "Provide correct `UserID`!" if user.nil?

      dataDir = "data/servers/#{event.server.id}"
      FileUtils.mkdir_p(dataDir) unless Dir.exist?(dataDir)
      File.new("#{dataDir}/warnings.json", "w").write("{}") unless File.exist?("#{dataDir}/warnings.json")
      warnData = JSON.parse(File.read("#{dataDir}/warnings.json"))

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**User <@#{user.id}> has 0 warnings**"
      end && return if warnData[user.id.to_s].nil?

      description = ""

      case (args[1])
      when "all"
        description = "Removed `all` warnings of user <@#{user.id}>"
        warnData.delete(user.id.to_s)
      when nil
        description = "Removed warning `№#{warnData[user.id.to_s].size}` of user <@#{user.id}>"
        warnData[user.id.to_s].delete_at(-1)
      else
        index = args[1].numeric? ? args[1].to_i.abs - 1 : -1
        index = warnData[user.id.to_s].size - 1 if index > warnData[user.id.to_s].size - 1
        description = "Removed warning `№#{index == -1 ? warnData[user.id.to_s].size : index + 1}` of user <@#{user.id}>"
        warnData[user.id.to_s].delete_at(index)
      end

      warnData.delete(user.id.to_s) if warnData[user.id.to_s] == []

      File.write("#{dataDir}/warnings.json", warnData.to_json)

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**#{description}**"
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Warnings in total: #{warnData[user.id.to_s].nil? ? 0 : warnData[user.id.to_s].size}")
      end
    end

    bot.command(:warnings, min_args: 1, max_args: 1) do |event|
      return if event.server.nil?
      return unless event.author.permission?(:ban_members)
      user = bot.member(event.server.id, proc do
        userId = event.message.mentions.first.nil? ? nil : event.message.mentions.first.id
        userId ||= args.first
      end.call)
      return "Provide correct `UserID`!" if user.nil?

      dataDir = "data/servers/#{event.server.id}"
      FileUtils.mkdir_p(dataDir) unless Dir.exist?(dataDir)
      File.new("#{dataDir}/warnings.json", "w").write("{}") unless File.exist?("#{dataDir}/warnings.json")
      warnData = JSON.parse(File.read("#{dataDir}/warnings.json"))

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**User <@#{user.id}> has 0 warnings**"
      end && return if warnData[user.id.to_s].nil?

      description = "**Warnings of user <@#{user.id}>**\n\n"
      i = 1

      warnData[user.id.to_s].each do |w|
        description += "**Case `№#{i}`**\n**Reason:** `#{w["reason"]}`\n**Issued by:** <@#{w["issuedBy"]}>\n**Timestamp:** <t:#{w["timestamp"]}>\n\n"
        i += 1
      end

      File.write("#{dataDir}/warnings.json", warnData.to_json)

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = description
      end
    end

    bot.command(:cleanupwarnings, min_args: 0, max_args: 0) do |event|
      return if event.server.nil?
      return unless event.author.permission?(:ban_members)

      dataDir = "data/servers/#{event.server.id}"
      FileUtils.mkdir_p(dataDir) unless Dir.exist?(dataDir)
      File.new("#{dataDir}/warnings.json", "w").write("{}") unless File.exist?("#{dataDir}/warnings.json")
      warnData = JSON.parse(File.read("#{dataDir}/warnings.json"))

      i = 0
      text = "nothing to remove"

      warnData.each do |key, value|
        if bot.member(event.server, key) == nil
          warnData.delete(key)
          i += 1
          text = "removed `#{i}` entries"
        end
      end

      File.write("#{dataDir}/warnings.json", warnData.to_json)

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = "**Successfully performed cleanup, #{text}**"
      end
    end

    bot.command(:resetwarnings, min_args: 0, max_args: 0) do |event|
      return if event.server.nil?
      return unless event.author.permission?(:administrator)

      dataDir = "data/servers/#{event.server.id}"
      FileUtils.mkdir_p(dataDir) unless Dir.exist?(dataDir)
      File.new("#{dataDir}/warnings.json", "w").write("{}") unless File.exist?("#{dataDir}/warnings.json")

      event.respond("**Are you sure about this action? `yes/no`**")
      description = "**Action cancelled**"

      event.user.await!(timeout: 15) do |wait|
        if wait.message.content.downcase == "yes"
          File.write("#{dataDir}/warnings.json", "{}")
          description = "**Successfully reset all warnings on this server**"
        end
        true
      end

      event.send_embed do |embed|
        embed.color = 3092790
        embed.description = description
      end
    end
  end
end
