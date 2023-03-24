# I decided to make global commands a separate thing cause easier to manage
require_relative "./Config.rb"
require_relative "./CommandHandler.rb"

module Global
  COOLDOWN = {}
end

register_eval = proc { |bot|
  bot.register_application_command(:eval, "Evaluates the given code and returns the result, developer-only command") { |cmd|
    cmd.string(:code, "Code to evaluate", required: true)
  }
}

register_manager = proc { |bot|
  bot.register_application_command(:commands, "Manage server commands / Управление командами сервера") { |cmd|
    cmd.subcommand(:register, "Register local commands on your server / Зарегистрировать команды на сервере") { |subcmd|
      subcmd.string(:language, "Choose which language to use inside the server / Выберите язык для команд на сервере", required: true, choices: { :ru => "ru", :en => "en" })
    }

    cmd.subcommand(:update, "Update local commands / Обновить локальные команды")
    cmd.subcommand(:remove, "Remove all local commands from the server / Удалить все локальные команды с сервера")
  }
}

CommandHandler.add_global_command(register_eval)
CommandHandler.add_global_command(register_manager)

# Handle eval command
handle_eval = proc { |bot|
  bot.application_command(:eval) { |handler|
    begin
      handler.defer

      code = handler.options["code"]
      (handler.send_message(content: "You don't have permission to use this command", ephemeral: true); return) unless handler.user.id == Config::DEVELOPER_ID

      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      description = "```\n"

      begin
        output = eval(code)
        embed.title = "Evaluation result"
      rescue Exception => e
        output = e.inspect
        embed.title = "Evaluation error"
      end

      embed.description = description + output.to_s + "\n```"
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Ruby version #{RUBY_VERSION}")
      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }
}

#
# Register commands category
#

handle_manager = proc { |bot|
  bot.application_command(:commands).subcommand(:register) { |handler|
    begin
      handler.defer

      (handler.send_message(content: "Use this command on your discord server / Используйте данную команду на сервере"); return) if handler.server_id.nil?
      (handler.send_message(content: "You don't have administrator permissions on this server / У вас нет прав администратора на этом сервере", ephemeral: true); return) unless (bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true or handler.user.id == Config::DEVELOPER_ID)
      (handler.send_message(content: "The command is on cooldown. Please wait a bit before trying again / Команда на перезарядке. Подождите немного перед следующим использованием\n" \
                            "Remaining time (s)/ Оставшееся время (c): `#{Global::COOLDOWN[handler.server_id.to_s]}`"); return) unless Global::COOLDOWN[handler.server_id.to_s].nil? or Global::COOLDOWN[handler.server_id.to_s] - Time.now.to_i < 0

      data = Utils.load_languages
      (handler.send_message(content: "Commands are already registered on your server, use /commands update to update them / Команды уже зарегистрированы на вашем сервере, используйте /commands update чтобы обновить их"); return) if data.key?(handler.server_id.to_s) == true

      data[handler.server_id.to_s] = handler.options["language"]
      Utils.update_languages(data)
      CommandHandler.register_commands(handler.server_id.to_s, handler.options["language"].to_s)
      Global::COOLDOWN[handler.server_id.to_s] = Time.now.to_i + 600 # 10 minute cooldown
      handler.send_message(content: "Successfully registered commands, this may take a while / Команды успешно зарегистированы, это займёт некоторое время")
    rescue LocalJumpError;     end
  }

  bot.application_command(:commands).subcommand(:update) { |handler|
    begin
      handler.defer
      (handler.send_message(content: "Use this command on your discord server / Используйте данную команду на сервере"); return) if handler.server_id.nil?
      (handler.send_message(content: "You don't have administrator permissions on this server / У вас нет прав администратора на этом сервере", ephemeral: true); return) unless (bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true or handler.user.id == Config::DEVELOPER_ID)
      data = Utils.load_languages
      (handler.send_message(content: "Commands are not registered on this server / Команды не зарегистрированы на этом сервере"); return) if data.key?(handler.server_id.to_s) == false
      (handler.send_message(content: "The command is on cooldown. Please wait a bit before trying again / Команда на перезарядке. Подождите немного перед следующим использованием\n" \
                            "Remaining time (s)/ Оставшееся время (c): `#{Global::COOLDOWN[handler.server_id.to_s] - Time.now.to_i}`"); return) unless Global::COOLDOWN[handler.server_id.to_s].nil? or Global::COOLDOWN[handler.server_id.to_s] - Time.now.to_i < 0

      CommandHandler.register_commands(handler.server_id.to_s, data[handler.server_id.to_s])
      Global::COOLDOWN[handler.server_id.to_s] = Time.now.to_i + 600 # 10 minute cooldown
      handler.send_message(content: "Successfully updated commands, this may take a while / Команды успешно обновлены, это займёт некоторое время")
    rescue LocalJumpError;     end
  }

  bot.application_command(:commands).subcommand(:remove) { |handler|
    begin
      handler.defer
      (handler.send_message(content: "Use this command on your discord server / Используйте данную команду на сервере"); return) if handler.server_id.nil?
      (handler.send_message(content: "You don't have administrator permissions on this server / У вас нет прав администратора на этом сервере", ephemeral: true); return) unless (bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true or handler.user.id == Config::DEVELOPER_ID)

      data = Utils.load_languages
      (handler.send_message(content: "Commands are not registered on this server / Команды не зарегистрированы на этом сервере"); return) if data.key?(handler.server_id.to_s) == false
      CommandHandler.delete_commands(handler.server_id.to_s)
      data.delete(handler.server_id.to_s)
      Utils.update_languages(data)
      handler.send_message(content: "Removed commands from this server / Команды удалены с данного сервера")
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_global_handler(handle_eval)
CommandHandler.add_global_handler(handle_manager)
