require_relative "../Database.rb"
require_relative "../CommandHandler.rb"
require_relative "../Config.rb"

register_warnings = lambda { |bot, server, language|
  if language == "en"
    bot.register_application_command(:warnings, "User warnings management", server_id: server) { |cmd|
      cmd.subcommand(:new, "Warn user") { |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
        subcmd.string(:reason, "Type in a warning reason", required: true)
      }
      cmd.subcommand(:remove, "Remove warning from a user") { |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
        subcmd.integer(:number, "Enter warn ordinal number, leave empty for the latest warn")
      }
      cmd.subcommand(:show, "Show warnings for a user") { |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
      }
      cmd.subcommand(:clear, "Clear all warnings for a user") { |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
      }
      cmd.subcommand(:me, "Check your warnings")
      cmd.subcommand(:drop, "Drop warnings database for this server")
      cmd.subcommand(:permissions, "Manage category permissions, admin-only command") { |subcmd|
        subcmd.string(:permission, "Choose permission to this category of commands", required: true, choices: { :"Administrator" => :administrator,
                                                                                                                :"Ban members" => :ban_members,
                                                                                                                :"Kick members" => :kick_members,
                                                                                                                :"Manage server" => :manage_server,
                                                                                                                :"Manage channels" => :manage_channels,
                                                                                                                :"Manage messages" => :manage_messages })
      }
    }
  else
    bot.register_application_command(:warnings, "User warnings management", server_id: server) { |cmd|
      cmd.subcommand(:new, "Выдать предупреждение") { |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
        subcmd.string(:reason, "Введите причину", required: true)
      }
      cmd.subcommand(:remove, "Убрать одно предупреждение пользователя") { |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
        subcmd.integer(:number, "Выберите номер предупреждения, оставьте пустым для последнего случая")
      }
      cmd.subcommand(:show, "Показать предупреждения пользователя") { |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
      }
      cmd.subcommand(:clear, "Убрать все предупреждения пользователя") { |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
      }
      cmd.subcommand(:me, "Показать свои предупреждения")
      cmd.subcommand(:drop, "Сбросить базу данных предупреждений для этого сервера")
      cmd.subcommand(:permissions, "Управление правами в данной категории команд, только для администраторов") { |subcmd|
        subcmd.string(:permission, "Выберите уровень доступа к командам этой категории", required: true, choices: { :"Администратор" => :administrator,
                                                                                                                    :"Бан пользователей" => :ban_members,
                                                                                                                    :"Кик пользователей" => :kick_members,
                                                                                                                    :"Управление сервером" => :manage_server,
                                                                                                                    :"Управление каналами" => :manage_channels,
                                                                                                                    :"Управление сообщениями" => :manage_messages })
      }
    }
  end
}

CommandHandler.add_command(register_warnings)

handle_warnings = proc { |bot, language|

  #
  # Add a warning
  #

  bot.application_command(:warnings).subcommand(:new) { |handler|
    begin
      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      handler.defer(ephemeral: false)

      if language[handler.server_id.to_s] == "en"
        #Basic checks
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        (handler.send_message(content: "**Max warning reason length is 256 symbols**", ephemeral: true); return) unless handler.options["reason"].length < 256

        # Get warn count, it automatically adds a new warning if count is less than 5
        count = Database::Warnings.insert_warning(handler.server_id.to_s, handler.options["user"].to_s, handler.options["reason"], handler.user.id.to_s, Time.now.to_i)
        count += 1
        (handler.send_message(content: "**The user has reached the limit of 5 warnings**", ephemeral: true); return) if count > 5

        embed.description = "**User <@#{handler.options["user"]}> has been warned**\nThis is case №#{count}"
        embed.add_field(name: "Reason", value: handler.options["reason"], inline: false)
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        (handler.send_message(content: "**Максимальная длина причины предупреждения - 256 символов**", ephemeral: true); return) unless handler.options["reason"].length < 256

        count = Database.insert_warning(handler.server_id.to_s, handler.options["user"].to_s, handler.options["reason"], handler.user.id.to_s, Time.now.to_i)
        count += 1
        (handler.send_message(content: "**Пользователь достиг предела из 5 предупреждений**", ephemeral: true); return) if count > 5

        embed.description = "**Пользователь <@#{handler.options["user"]}> предупрежден**\nЭто случай №#{count}"
        embed.add_field(name: "Причина", value: handler.options["reason"], inline: false)
      end

      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }

  #
  # Show warnings
  #

  bot.application_command(:warnings).subcommand(:show) { |handler|
    begin
      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      handler.defer(ephemeral: false)
      data = Database::Warnings.get_warnings(handler.server_id.to_s, handler.options["user"].to_s)
      i = 1

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        (embed.description = "**User <@#{handler.options["user"]}> has no warnings**"; handler.send_message(embeds: [embed]); return) unless data[0] > 0
        embed.description = "**Warnings for user** <@#{handler.options["user"]}>"
        data[1].each do |warn|
          embed.add_field(name: "Case №#{i}", value: "Reason: #{warn[0]}\nBy: <@#{warn[1]}>\nTimestamp: <t:#{warn[2]}>\n[Expires in #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} days]", inline: true)
          i += 1
        end
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        (embed.description = "**У пользователя <@#{handler.options["user"]}> нет предупреждений**"; handler.send_message(embeds: [embed]); return) unless data[0] > 0
        embed.description = "**Предупреждения пользователя** <@#{handler.options["user"]}>"
        data[1].each do |warn|
          embed.add_field(name: "Случай №#{i}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
          i += 1
        end
      end
    rescue LocalJumpError;     end
  }

  #
  # Show personal warnings
  #

  bot.application_command(:warnings).subcommand(:me) { |handler|
    embed = Discordrb::Webhooks::Embed.new
    embed.color = Config::DEFAULT_EMBED_COLOR
    handler.defer
    data = Database::Warnings.get_warnings(handler.server_id.to_s, handler.user.id.to_s)
    i = 1

    if language[handler.server_id.to_s] == "en"
      handler.send_message(content: "**User <@#{handler.user.id}> has no warnings**") unless data[0] > 0
      embed.description = "**Warnings for user** <@#{handler.user.id}>"
      data[1].each do |warn|
        embed.add_field(name: "Case №#{i}", value: "Reason: #{warn[0]}\nBy: <@#{warn[1]}>\nTimestamp: <t:#{warn[2]}>\n[Expires in #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} days]", inline: true)
        i += 1
      end
    else
      handler.send_message(content: "**У пользователя <@#{handler.user.id}> нет предупреждений**") unless data[0] > 0
      embed.description = "**Предупреждения пользователя** <@#{handler.user.id}>"
      data[1].each do |warn|
        embed.add_field(name: "Случай №#{i}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
        i += 1
      end
    end

    handler.send_message(embeds: [embed])
  }

  #
  # Remove one warning
  #

  bot.application_command(:warnings).subcommand(:remove) { |handler|
    begin
      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      handler.defer(ephemeral: false)
      number = handler.options["number"].nil? ? nil : handler.options["number"]

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        deleted_number = Database::Warnings.remove_warning(handler.server_id.to_s, handler.options["user"].to_s, number)
        delted_number ||= 0
        embed.description = "**User <@#{handler.option["user"]}> has no warnings**" if deleted_number.zero?
        embed.description = "**Removed warning №#{deleted_number} for user** <@#{handler.options["user"]}>"
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        deleted_number = Database::Warnings.remove_warning(handler.server_id.to_s, handler.options["user"].to_s, number)
        delted_number ||= 0
        embed.description = "**У пользователя <@#{handler.options["user"]}> нет предупреждений**" if deleted_number.zero?
        embed.description = "**Убрано предупреждение №#{deleted_number} у пользователя** <@#{handler.options["user"]}>"
      end

      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }

  #
  # Remove all warnings for a user
  #

  bot.application_command(:warnings).subcommand(:clear) { |handler|
    begin
      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR
      handler.defer(ephemeral: false)

      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        Database::Warnings.clear_warnings(handler.server_id.to_s, handler.options["user"].to_s)
        embed.description = "**Removed all warnings for user** <@#{handler.options["user"]}>"
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(Database::ServerSettings.get_setting(handler.server_id.to_s, "warnperms")) == false
        Database::Warnings.clear_warnings(handler.server_id.to_s, handler.options["user"].to_s)
        embed.description = "**Убраны все предупреждения пользователя** <@#{handler.options["user"]}>"
      end

      handler.send_message(embeds: [embed])
    rescue LocalJumpError;     end
  }

  #
  # Le funny
  #

  bot.application_command(:warnings).subcommand(:drop) { |handler|
    begin
      handler.defer(ephemeral: false)
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**"); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        Database::Warnings.drop_warnings(handler.server_id.to_s)
        handler.respond(content: "**Dropped all data about warnings on this server**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**"); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        Database::Warnings.drop_warnings(handler.server_id.to_s)
        handler.respond(content: "**Сброшены все данные о предупреждениях на данном сервере**")
      end
    rescue LocalJumpError;     end
  }

  bot.application_command(:warnings).subcommand(:permissions) { |handler|
    begin
      handler.defer(ephemeral: false)
      if language[handler.server_id.to_s] == "en"
        (handler.send_message(content: "**You don't have permission to run this command**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Set `/warnings` permissions to #{handler.options["permission"]}**")
      else
        (handler.send_message(content: "**У вас нет прав на использование данной команды**", ephemeral: true); return) if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == false
        handler.send_message(content: "**Установлены права на использование `/warnings`: #{Enums::DISCORD_PERMISSIONS_RU[handler.options["permission"].to_sym]}**")
      end

      Database::ServerSettings.set_setting(handler.server_id.to_s, "warnperms", handler.options["permission"])
    rescue LocalJumpError;     end
  }
}

CommandHandler.add_handler(handle_warnings)
