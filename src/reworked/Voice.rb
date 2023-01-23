QUEUE = {}
PLAYERS = {}
FREEZE = {}

module Commands
  def self.voice(bot, caldera)
    node = caldera.add_node(uri: "http://localhost:1337", authorization: "sekrekt")

    bot.voice_state_update from: bot.bot_app.id do |update|
      caldera.update_voice_state(update.server.id, session_id: update.session_id)
    end

    bot.voice_server_update do |update|
      caldera.update_voice_state(update.server.id.to_s, event: { token: update.token, guild_id: update.server.id.to_s, endpoint: update.endpoint })
    end

    bot.command(:voice, min_args: 1, max_args: 2) do |event, *args|
      case args.first
      when "play"
        return "Provide the correct `link` to play" if args[1].nil?
        return "You must be connnected to a voice channel" if event.author.voice_channel.nil?
        bot.gateway.send_voice_state_update(event.server.id, event.author.voice_channel.id, false, true)
        player = PLAYERS[event.server.id].nil? ? caldera.get_player(event.server.id) : PLAYERS[event.server.id]

        begin
          player ||= caldera.connect(event.server.id, event.author.voice_channel.id, timeout: 10)
        rescue Timeout::Error
          return "Failed to connect to the voice channel"
        end

        track = player.load_tracks(args[1])
        return "Could not find the track" if track.first.nil?
        QUEUE[event.server.id] = [] if QUEUE[event.server.id].nil?

        if PLAYERS[event.server.id].nil?
          PLAYERS[event.server.id] = player
          player.on :track_end do
            if FREEZE[event.server.id] == true
              FREEZE[event.server.id] = false
            else
              skipped = QUEUE[event.server.id].first
              QUEUE[event.server.id].shift
              player.play(QUEUE[event.server.id].first) if QUEUE[event.server.id].size > 0
              description = ""

              if QUEUE[event.server.id] == []
                bot.gateway.send_voice_state_update(event.server.id, nil, false, false)
                description = "**Nothing to play, disconnected**"
              else
                description = "**Played: [#{skipped.title}](#{skipped.uri})\nNext: [#{QUEUE[event.server.id].first.title}](#{QUEUE[event.server.id].first.uri})**"
              end

              event.send_embed do |embed|
                embed.color = 3092790
                embed.description = description
              end
            end
          end
        end

        player.play(track.first) if QUEUE[event.server.id] == []
        return "Reached the queue limit of `20 tracks`" unless QUEUE[event.server.id].size < 20
        QUEUE[event.server.id] << track.first
        player.unpause

        event.send_embed do |embed|
          embed.color = 3092790
          embed.description = "**Added `#{track.first.title}` to the queue**"
        end
      when "pause"
        return "You must be connected to the voice channel" if event.author.voice_channel.nil?
        return "Nothing is playing right now" if QUEUE[event.server.id].nil? or QUEUE[event.server.id] == []

        PLAYERS[event.server.id].pause

        event.send_embed do |embed|
          embed.color = 3092790
          embed.title = "Paused the playback"
        end
      when "resume"
        return "You must be connected to the voice channel" if event.author.voice_channel.nil?
        return "Nothing is playing right now" if QUEUE[event.server.id].nil? or QUEUE[event.server.id] == []

        PLAYERS[event.server.id].unpause

        event.send_embed do |embed|
          embed.color = 3092790
          embed.title = "Resumed the playback"
        end
      when "queue"
        return "The queue is empty" if QUEUE[event.server.id].nil? or QUEUE[event.server.id] == []

        description = ""
        i = 1

        QUEUE[event.server.id].each do |track|
          description += "**[#{i}. #{track.title}](#{track.uri})**\n"
          i += 1
        end

        event.send_embed do |embed|
          embed.color = 3092790
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Current queue")
          embed.description = description
        end
      when "next", "skip"
        return "You must be connected to the voice channel" if event.author.voice_channel.nil?
        return "The queue is empty" if QUEUE[event.server.id].nil? or QUEUE[event.server.id] == []

        FREEZE[event.server.id] = true
        skipped = QUEUE[event.server.id].first
        QUEUE[event.server.id].shift
        PLAYERS[event.server.id].play(QUEUE[event.server.id].first) if QUEUE[event.server.id].size > 0
        description = ""

        if QUEUE[event.server.id] == []
          bot.gateway.send_voice_state_update(event.server.id, nil, false, false)
          description = "**Nothing to play, disconnected**"
        else
          description = "**Played: [#{skipped.title}](#{skipped.uri})\nNext: [#{QUEUE[event.server.id].first.title}](#{QUEUE[event.server.id].first.uri})**"
        end

        event.send_embed do |embed|
          embed.color = 3092790
          embed.description = description
        end
      when "stop"
        return "You must be connected to the voice channel" if event.author.voice_channel.nil?
        return "The queue is empty" if QUEUE[event.server.id].nil? or QUEUE[event.server.id] == []

        FREEZE[event.server.id] = true
        QUEUE[event.server.id] = []
        PLAYERS[event.server.id].pause
        bot.gateway.send_voice_state_update(event.server.id, nil, false, false)

        event.send_embed do |embed|
          embed.color = 3092790
          embed.title = "Stopped the playback and disconnected"
        end
      end
    end
  end
end
