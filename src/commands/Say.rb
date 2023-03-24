require_relative "../CommandHandler.rb"

register_say = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:say, "Send a message from bot", server_id: server) { |cmd|
      cmd.string(:text, "Message text", required: true)
      cmd.string(:replyid, "Message id to reply to", required: false)
    }
  else
    bot.register_application_command(:say, "Отправить сообщение от имени бота", server_id: server) { |cmd|
      cmd.string(:text, "Текст сообщения", required: true)
      cmd.string(:replyid, "ID сообщения на которое надо ответить", required: false)
    }
  end
}

CommandHandler.add_command(register_say)

handle_say = proc { |bot, language|
  bot.application_command(:say) { |handler|
    begin
      handler.defer
      reply = nil
      reply = { message_id: handler.options["replyid"] } unless handler.options["replyid"].nil?
      begin
        if language[handler.server_id.to_s] == "en"
          (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "embedperms")) == false
          handler.send_message(content: "**Message was successfully sent**")
        else
          (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "embedperms")) == false
          handler.send_message(content: "**Сообщение успешно отправлено**")
        end
        handler.channel.send_message(handler.options["text"], false, nil, nil, nil, reply, nil)
      rescue Discordrb::Errors::NoPermission
        handler.send_message(content: "**I'm not allowed to send messages in this channel**") if language[handler.server_id.to_s] == "en"
        handler.send_message(content: "**У меня нет прав отправлять сообщения в данный канал**") if language[handler.server_id.to_s] == "ru"
      end
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_say)
