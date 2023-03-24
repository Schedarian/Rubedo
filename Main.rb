require "bundler/setup"
require "discordrb"
require "json"
require "net/http"
require "uri"
require "fileutils"
require "sqlite3"

require_relative "src/Config.rb"
require_relative "src/Initializer.rb"

module Rubedo
  bot = Discordrb::Bot.new(token: Config::BOT_TOKEN, intents: :all)
  bot.init_cache
  bot.ready {
    bot.dnd
    Initializer.run(bot)
  }
  bot.run
end
