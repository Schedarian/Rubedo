require_relative "../Utils.rb"

module Voice
  include Utils

  QUEUE = {}
  PLAYERS = {}
  FREEZE = {}

  def self.register_en(bot, server)
    bot.register_application_command(:voice, "Music player", server_id: server) do |cmd|
      cmd.subcommand(:play, "Play a track by link") do |subcmd|
        subcmd.string(:link, "Type in a link", required: true)
      end

      cmd.subcommand(:pause, "Pause the playback")
      cmd.subcommand(:resume, "Resume the playback")
      cmd.subcommand(:queue, "Show the current queue")
      cmd.subcommand(:next, "Play next track")
      cmd.subcommand(:stop, "Stop playback and disconnect")
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:voice, "Аудиопроигрыватель", server_id: server) do |cmd|
      cmd.subcommand(:play, "Воспроизвести трек по ссылке") do |subcmd|
        subcmd.string(:link, "Введите ссылку", required: true)
      end

      cmd.subcommand(:pause, "Поставить воспроизведение на паузу")
      cmd.subcommand(:resume, "Продолжить воспроизведение")
      cmd.subcommand(:queue, "Показать очередь треков")
      cmd.subcommand(:next, "Запустить следующий трек")
      cmd.subcommand(:stop, "Остановить воспроизведение и отключить от канала")
    end
  end

  def self.handle(bot, caldera)
    node = caldera.add_node(uri: "http://localhost:1337", authorization: "sekrekt")

    bot.voice_state_update from: bot.bot_app.id do |update|
      caldera.update_voice_state(update.server.id, session_id: update.session_id)
    end

    bot.voice_server_update do |update|
      caldera.update_voice_state(update.server.id, event: { token: update.token, guild_id: update.server.id.to_s, endpoint: update.endpoint })
    end

    bot.application_command(:voice).subcommand(:play) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "Вы не подключены к голосовому каналу")
        else
          bot.gateway.send_voice_state_update(handler.server_id, handler.user.voice_channel.id, false, true)
          player = PLAYERS[handler.server_id.to_s].nil? ? caldera.get_player(handler.server_id) : PLAYERS[handler.server_id.to_s]

          begin
            player ||= caldera.connect(handler.server_id, handler.user.voice_channel.id, timeout: 10)
          rescue Timeout::Error
            handler.channel.send_message("Не удалось подключиться к голосовому каналу")
          end

          tracks = player.load_tracks(handler.options["link"])
          QUEUE[handler.server_id.to_s] = [] if QUEUE[handler.server_id.to_s].nil?

          if tracks.first.nil?
            handler.respond(content: "Не удалось найти трек")
          else
            if PLAYERS[handler.server_id.to_s].nil?
              PLAYERS[handler.server_id.to_s] = player
              player.on :track_end do
                if FREEZE[handler.server_id.to_s] == true
                  FREEZE[handler.server_id.to_s] = false
                else
                  skipped = QUEUE[handler.server_id.to_s].first
                  QUEUE[handler.server_id.to_s].shift
                  player.play(QUEUE[handler.server_id.to_s].first) if QUEUE[handler.server_id.to_s].size > 0
                  description = ""

                  if QUEUE[handler.server_id.to_s] == []
                    bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)
                    handler.channel.send_message("**Нечего воспроизводить, выхожу из канала**")
                  else
                    handler.channel.send_embed do |embed|
                      embed.color = 13775422
                      embed.description = "**Закончился: [#{skipped.title}](#{skipped.uri})\nСледующий: [#{QUEUE[handler.server_id.to_s].first.title}](#{QUEUE[handler.server_id.to_s].first.uri})**"
                    end
                  end
                end
              end
            end

            player.play(tracks.first) if QUEUE[handler.server_id.to_s] == []
            if QUEUE[handler.server_id.to_s].size < 20
              QUEUE[handler.server_id.to_s] << tracks.first
              player.unpause

              embed = Discordrb::Webhooks::Embed.new
              embed.color = 13775422
              embed.description = "**Добавлен `#{tracks.first.title}` в очередь**"

              handler.respond(embeds: [] << embed)
            else
              handler.respond(content: "Достигнут лимит из 20 треков в плейлисте")
            end
          end
        end
      else
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "You must be connected to a voice channel")
        else
          bot.gateway.send_voice_state_update(handler.server_id, handler.user.voice_channel.id, false, true)
          player = PLAYERS[handler.server_id.to_s].nil? ? caldera.get_player(handler.server_id) : PLAYERS[handler.server_id.to_s]

          begin
            player ||= caldera.connect(handler.server_id, handler.user.voice_channel.id, timeout: 10)
          rescue Timeout::Error
            handler.channel.send_message("Failed to connect to the voice channel")
          end

          tracks = player.load_tracks(handler.options["link"])
          QUEUE[handler.server_id.to_s] = [] if QUEUE[handler.server_id.to_s].nil?

          if tracks.first.nil?
            handler.respond(content: "Could not find the track")
          else
            if PLAYERS[handler.server_id.to_s].nil?
              PLAYERS[handler.server_id.to_s] = player
              player.on :track_end do
                if FREEZE[handler.server_id.to_s] == true
                  FREEZE[handler.server_id.to_s] = false
                else
                  skipped = QUEUE[handler.server_id.to_s].first
                  QUEUE[handler.server_id.to_s].shift
                  player.play(QUEUE[handler.server_id.to_s].first) if QUEUE[handler.server_id.to_s].size > 0
                  description = ""

                  if QUEUE[handler.server_id.to_s] == []
                    bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)
                    description = "**Nothing to play, disconnected**"
                  else
                    description = "**Played: [#{skipped.title}](#{skipped.uri})\nNext: [#{QUEUE[handler.server_id.to_s].first.title}](#{QUEUE[handler.server_id.to_s].first.uri})**"
                  end

                  handler.channel.send_embed do |embed|
                    embed.color = 13775422
                    embed.description = description
                  end
                end
              end
            end

            player.play(tracks.first) if QUEUE[handler.server_id.to_s] == []
            if QUEUE[handler.server_id.to_s].size < 20
              QUEUE[handler.server_id.to_s] << tracks.first
              player.unpause

              embed = Discordrb::Webhooks::Embed.new
              embed.color = 13775422
              embed.description = "**Added `#{tracks.first.title}` to the queue**"

              handler.respond(embeds: [] << embed)
            else
              handler.respond(content: "Reached the queue limit of 20 tracks")
            end
          end
        end
      end
    end

    bot.application_command(:voice).subcommand(:pause) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "Вы не подключены к голосовому каналу")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "В данный момент ничего не воспроизводится")
          else
            PLAYERS[handler.server_id.to_s].pause
            handler.respond(content: "Воспроизведение приостановлено")
          end
        end
      else
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "You must be connected to the voice channel")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "Nothing is playing right now")
          else
            PLAYERS[handler.server_id.to_s].pause
            handler.respond(content: "Paused the playback")
          end
        end
      end
    end

    bot.application_command(:voice).subcommand(:resume) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "Вы не подключены к голосовому каналу")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "В данный момент ничего не воспроизводится")
          else
            PLAYERS[handler.server_id.to_s].unpause
            handler.respond(content: "Воспроизведение запущено")
          end
        end
      else
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "You must be connected to the voice channel")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "Nothing is playing right now")
          else
            PLAYERS[handler.server_id.to_s].unpause
            handler.respond(content: "Resumed the playback")
          end
        end
      end
    end

    bot.application_command(:voice).subcommand(:queue) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      embed = Discordrb::Webhooks::Embed.new

      if lang == "ru"
        if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
          handler.respond(content: "Список треков пустой")
        else
          description = ""
          i = 1

          QUEUE[handler.server_id.to_s].each do |track|
            description += "**[#{i}. #{track.title}](#{track.uri})**\n"
            i += 1
          end

          embed.color = 13775422
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Список треков")
          embed.description = description
        end
      else
        if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
          handler.respond(content: "The queue is empty")
        else
          description = ""
          i = 1

          QUEUE[handler.server_id.to_s].each do |track|
            description += "**[#{i}. #{track.title}](#{track.uri})**\n"
            i += 1
          end

          embed.color = 13775422
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "Current queue")
          embed.description = description
        end
      end

      handler.respond(embeds: [] << embed)
    end

    bot.application_command(:voice).subcommand(:next) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      embed = Discordrb::Webhooks::Embed.new

      if lang == "ru"
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "Вы не подключены к голосовому каналу")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "В данный момент ничего не воспроизводится")
          else
            FREEZE[handler.server_id.to_s] = true
            skipped = QUEUE[handler.server_id.to_s].first
            QUEUE[handler.server_id.to_s].shift
            PLAYERS[handler.server_id.to_s].play(QUEUE[handler.server_id.to_s].first) if QUEUE[handler.server_id.to_s].size > 0
            description = ""

            if QUEUE[handler.server_id.to_s] == []
              bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)
              description = "**Нечего воспроизводить, выхожу из канала**"
            else
              description = "**Закончился: [#{skipped.title}](#{skipped.uri})\nСледующий: [#{QUEUE[handler.server_id.to_s].first.title}](#{QUEUE[handler.server_id.to_s].first.uri})**"
            end
            embed.color = 13775422
            embed.description = description
          end
        end
      else
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "You must be connected to the voice channel")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "Nothing is playing right now")
          else
            FREEZE[handler.server_id.to_s] = true
            skipped = QUEUE[handler.server_id.to_s].first
            QUEUE[handler.server_id.to_s].shift
            PLAYERS[handler.server_id.to_s].play(QUEUE[handler.server_id.to_s].first) if QUEUE[handler.server_id.to_s].size > 0
            description = ""

            if QUEUE[handler.server_id.to_s] == []
              bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)
              description = "**Nothing to play, disconnected**"
            else
              description = "**Played: [#{skipped.title}](#{skipped.uri})\nNext: [#{QUEUE[handler.server_id.to_s].first.title}](#{QUEUE[handler.server_id.to_s].first.uri})**"
            end
            embed.color = 13775422
            embed.description = description
          end
        end
      end

      handler.respond(embeds: [] << embed)
    end

    bot.application_command(:voice).subcommand(:stop) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "Вы не подключены к голосовому каналу")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "Список треков пустой")
          else
            FREEZE[handler.server_id.to_s] = true
            QUEUE[handler.server_id.to_s] = []
            PLAYERS[handler.server_id.to_s].pause
            bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)

            handler.respond(content: "**Воспроизведение остановлено, выхожу из канала**")
          end
        end
      else
        if bot.member(handler.server_id, handler.user.id).voice_channel.nil?
          handler.respond(content: "You must be connected to the voice channel")
        else
          if QUEUE[handler.server_id.to_s].nil? or QUEUE[handler.server_id.to_s] == []
            handler.respond(content: "The queue is empty")
          else
            FREEZE[handler.server_id.to_s] = true
            QUEUE[handler.server_id.to_s] = []
            PLAYERS[handler.server_id.to_s].pause
            bot.gateway.send_voice_state_update(handler.server_id, nil, false, false)

            handler.respond(content: "**Stopped the playback and disconnected**")
          end
        end
      end
    end
  end
end
