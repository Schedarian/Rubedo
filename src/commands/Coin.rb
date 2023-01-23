require_relative "../Utils.rb"

module Coin
  include Utils

  def self.register_en(bot, server)
    bot.register_application_command(:coin, "Flip a coin", server_id: server)
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:coin, "Подбросить монетку", server_id: server)
  end

  def self.handle(bot)
    bot.application_command(:coin) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        handler.respond(content: "#{rand(0..1) == 1 ? ":coin: **Орёл**" : ":coin: **Решка**"}")
      else
        handler.respond(content: "#{rand(0..1) == 1 ? ":coin: **Heads**" : ":coin: **Tails**"}")
      end
    end
  end
end
