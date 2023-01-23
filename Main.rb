require "bundler/setup"
require "discordrb"
require "json"
require "net/http"
require "uri"
require "fileutils"
require "caldera"
require "sqlite3"

require_relative "src/GlobalCommands.rb"
require_relative "src/ServerCommands.rb"
require_relative "src/Events.rb"
require_relative "src/Database.rb"
require_relative "src/Config.rb"

module Rubedo
  $users = 0
  bot = Discordrb::Bot.new(token: Config.get_token, intents: :all)
  caldera = Caldera::Client.new(num_shards: 1, user_id: 840665896556560435, connect: lambda { |gid, cid|
                                  bot.gateway.send_voice_state_update(gid, cid, false, true)
                                })

  bot.init_cache
  bot.ready do
    bot.dnd
    GlobalCommands.register_global_commands(bot)
    GlobalCommands.handle_global_commands(bot)
    Commands.handle_all(bot, caldera)

    Thread.new do
      loop do
        $users = 0
        bot.servers.each do |key, value|
          $users += value.member_count
        end

        bot.watching = ("#{$users} users")
        sleep(900)
      end
    end
  end

  bot.run
end
