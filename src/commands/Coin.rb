require_relative "../CommandHandler.rb"

register_coin = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:coin, "Flip a coin", server_id: server)
  else
    bot.register_application_command(:coin, "Подбросить монетку", server_id: server)
  end
}

CommandHandler.add_command(register_coin)

handle_coin = proc { |bot, language|
  bot.application_command(:coin) { |handler|
    if language[handler.server_id.to_s] == "en"
      handler.respond(content: "#{rand(0..1) == 1 ? ":coin: **Heads**" : ":coin: **Tails**"}")
    else
      handler.respond(content: "#{rand(0..1) == 1 ? ":coin: **Орёл**" : ":coin: **Решка**"}")
    end
  }
}

CommandHandler.add_handler(handle_coin)
