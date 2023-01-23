START_TIME = Time.now

module Commands
  def self.info(bot)
    bot.command(:info, min_args: 1, max_args: 2) do |event, *args|
      case (args.first)
      when "user"
        user = bot.user(proc do
          userId = event.message.mentions.first.nil? ? nil : event.message.mentions.first.id
          userId ||= args[1]
        end.call)
        return "`User ID` is invalid" if user.nil?

        event.send_embed do |embed|
          embed.color = 3092790
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{user.name}##{user.discriminator}", icon_url: user.avatar_url)
          embed.add_field(name: "Basic info", value: "**ID:** #{user.id}\n**Bot account?** #{user.current_bot? == true ? "Yes" : "No"}\n**Status:** #{user.status.to_s.capitalize!}\n**Account registered:** <t:#{user.creation_time.to_i}> (<t:#{user.creation_time.to_i}:R>)", inline: true)

          unless event.server.nil?
            member = bot.member(event.server.id, user.id)
            roles = ""
            member.roles.each do |role|
              next if role.name == "@everyone"
              roles = roles + "<@&#{role.id}> "
            end

            embed.add_field(name: "Server member info", value: "**Nickname:** #{member.display_name}\n**Nitro booster?** #{member.boosting? == true ? "Yes" : "No"}\n**Joined server:** <t:#{member.joined_at.to_i}> (<t:#{member.joined_at.to_i}:R>)", inline: true)
            embed.add_field(name: "Roles", value: "#{roles == "" ? "[None]" : roles}", inline: false)
          else
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Use command in a server for more info")
          end
        end
      when "server"
        return if event.server.nil?
        event.send_embed do |embed|
          embed.color = 3092790
          embed.title = event.server.name
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url)
          embed.description = "**ID:** #{event.server.id}\n**Owner:** <@#{event.server.owner.id}>\n**Creation date:** <t:#{event.server.creation_time.to_i}> (<t:#{event.server.creation_time.to_i}:R>)\n**Members:** #{event.server.member_count} (#{event.server.bot_members.size} bots)\n**Channels:** #{event.server.channels.size}\n**Roles:** #{event.server.roles.size}\n**Emojis:** #{event.server.emoji.size}\n**Boosts:** #{event.server.booster_count} (Level #{event.server.boost_level})\n**Verification level:** #{event.server.verification_level.to_s.capitalize!}\n**Content filtering:** #{event.server.content_filter_level.to_s.capitalize!}"
        end
      when "bot"
        event.send_embed do |embed|
          embed.color = 3092790
          embed.title = bot.profile.distinct
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: bot.profile.avatar_url)
          embed.add_field(name: "Stats", value: "**Servers:** #{bot.servers.size}\n**Users:** #{$users}\n**Uptime:** #{(Time.now - START_TIME).to_i / 3600} hours", inline: true)
          embed.add_field(name: "Useful links", value: "[Invite link](https://discord.com/api/oauth2/authorize?client_id=840665896556560435&permissions=0&scope=bot)", inline: true)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Written using Discordrb library")
        end
      end
    end
  end
end
