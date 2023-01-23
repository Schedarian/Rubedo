# Initialize all global commands and handle them
# Plus choose server language

require_relative "ServerCommands.rb"

module GlobalCommands
  COOLDOWN = {}
  COMMAND_ID = "1067131137476005923"

  def self.register_global_commands(bot)
    bot.register_application_command(:commands, "Manage server commands / Управление командами сервера") do |cmd|
      cmd.subcommand(:register, "Register local commands on your server / Зарегистрировать команды на сервере") do |subcmd|
        subcmd.string(:language, "Choose which language to use inside the server / Выберите язык для команд на сервере", required: true, choices: { :ru => "ru", :en => "en" })
      end

      cmd.subcommand(:update, "Update local commands / Обновить локальные команды")
      cmd.subcommand(:remove, "Remove all local commands from the server / Удалить все локальные команды с сервера")
    end
  end

  def self.handle_global_commands(bot)
    bot.application_command(:commands).subcommand(:register) do |handler|
      if handler.server_id.nil?
        handler.respond(content: "Use this command on your discord server / Используйте данную команду на сервере")
      else
        data = JSON.parse(File.read("data/languages.json"))
        server = handler.server_id.to_s

        if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true
          if data.key?(server) == true
            handler.respond(content: "Commands are already registered on this server") if data[server] == "en"
            handler.respond(content: "Команды уже зарегистрированы на этом сервере") if data[server] == "ru"
          else
            if COOLDOWN[server].nil? or COOLDOWN[server] - Time.now.to_i < 0
              data[server] = "#{handler.options["language"]}"
              File.write("data/languages.json", data.to_json)
              handler.respond(content: "Successfully registered commands on this server, this may take a few minutes to complete") if data[server] == "en"
              handler.respond(content: "Команды успешно зарегистрированы на сервере, процесс может занять пару минут") if data[server] == "ru"
              Commands.register_all_en(bot, server) if data[server] == "en"
              Commands.register_all_ru(bot, server) if data[server] == "ru"
              COOLDOWN[server] = Time.now.to_i + 600
            else
              handler.respond(content: "The command is on a cooldown. Wait for **#{COOLDOWN[server] - Time.now.to_i}** seconds before you can use it again")
            end
          end
        else
          if data.key?(server) == true
            if data[server] == "ru"
              handler.respond(content: "У вас нет прав уровня <администратор> на этом сервере", ephemeral: true)
            else
              handler.respond(content: "You don't have <administrator> perimssion on this server", ephemeral: true)
            end
          else
            handler.respond(content: "You don't have <administrator> perimssion on this server", ephemeral: true)
          end
        end
      end
    end

    bot.application_command(:commands).subcommand(:update) do |handler|
      if handler.server_id.nil?
        handler.respond(content: "Use this command on your discord server / Используйте данную команду на сервере")
      else
        data = JSON.parse(File.read("data/languages.json"))
        server = handler.server_id.to_s

        if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true
          if data.key?(server) == true
            response = Commands.update_en(bot, server) if data[server] == "en"
            response = Commands.update_ru(bot, server) if data[server] == "ru"

            handler.respond(content: response == true ? "Команды успешно обновлены на этом сервере" : "На данный момент нет никаких обновлений") if data[server] == "ru"
            handler.respond(content: response == true ? "Successfully updated commands on this server" : "There is nothing to update right now") if data[server] == "en"
          else
            handler.respond(content: "Register commands first by using </commands register:#{COMMAND_ID}>")
          end
        else
          if data.key?(server) == true
            if data[server] == "ru"
              handler.respond(content: "У вас нет прав уровня <администратор> на этом сервере", ephemeral: true)
            else
              handler.respond(content: "You don't have <administrator> perimssion on this server", ephemeral: true)
            end
          else
            handler.respond(content: "You don't have <administrator> perimssion on this server", ephemeral: true)
          end
        end
      end
    end

    bot.application_command(:commands).subcommand(:remove) do |handler|
      if handler.server_id.nil?
        handler.respond(content: "Use this command on your discord server / Используйте данную команду на сервере")
      else
        data = JSON.parse(File.read("data/languages.json"))
        server = handler.server_id.to_s

        if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true
          if data.key?(server) == true
            handler.respond(content: "Команды успешно удалены с этого сервера, это может занять пару минут") if data[server] == "ru"
            handler.respond(content: "Successfully removed all local commands from this server, this may take a few minutes") if data[server] == "en"
            data.delete(server)
            File.write("data/languages.json", data.to_json)
            Commands.remove_all(bot, server)
          else
            handler.respond(content: "Register commands first by using </commands register:#{COMMAND_ID}>")
          end
        else
          handler.respond(content: "You don't have <administrator> perimssion on this server", ephemeral: true)
        end
      end
    end
  end
end
