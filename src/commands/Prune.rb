require_relative "../CommandHandler.rb"
#require_relative "../Config.rb"

register_prune = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:prune, "Prune messages", server_id: server) { |cmd|
      cmd.integer(:amount, "Amount of messages to prune (2-100)", required: true)
    }
  else
    bot.register_application_command(:prune, "Очистить сообщения", server_id: server) { |cmd|
      cmd.integer(:amount, "Количество удаляемых сообщений (2-100)", required: true)
    }
  end
}

CommandHandler.add_command(register_prune)

handle_prune = proc { |bot, language|
  bot.application_command(:prune) { |handler|
    count = handler.options["amount"].to_i
    count = 2 if count < 2
    count = 100 if count > 100
    handler.defer

    begin
      bot.channel(handler.channel_id, handler.server_id).prune(count)
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "**I'm not allowed to delete messages in this channel**") if language[handler.server_id.to_s] == "en"
      handler.send_message(content: "**У меня нет прав удалять сообщения в данном канале**") if language[handler.server_id.to_s] == "ru"
    end

    if language[handler.server_id.to_s] == "en"
      (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == false
      handler.send_message(content: "**Successfully pruned #{count} messages from <##{handler.channel_id}>**", ephemeral: true)
    else
      (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == false
      handler.send_message(content: "**Успешно удалено #{count} сообщений в <##{handler.channel_id}>**")
    end
  }
}

CommandHandler.add_handler(handle_prune)
