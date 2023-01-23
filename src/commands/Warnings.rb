require_relative "../Utils.rb"
require_relative "../Database.rb"

module Warnings
  include Utils
  include Database

  def self.register_en(bot, server)
    bot.register_application_command(:warnings, "User warnings management", server_id: server) do |cmd|
      cmd.subcommand(:new, "Warn user") do |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
        subcmd.string(:reason, "Type in a warning reason", required: true)
      end
      cmd.subcommand(:remove, "Remove warning from a user") do |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
        subcmd.integer(:number, "Enter warn ordinal number, leave empty for the latest warn")
      end
      cmd.subcommand(:show, "Show warnings for a user") do |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
      end
      cmd.subcommand(:clear, "Clear all warnings for a user") do |subcmd|
        subcmd.user(:user, "Choose a user", required: true)
      end
      cmd.subcommand(:drop, "Drop warnings database for this server")
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:warnings, "User warnings management", server_id: server) do |cmd|
      cmd.subcommand(:new, "Выдать предупреждение") do |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
        subcmd.string(:reason, "Введите причину", required: true)
      end
      cmd.subcommand(:remove, "Убрать одно предупреждение пользователя") do |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
        subcmd.integer(:number, "Выберите номер предупреждения, оставьте пустым для последнего случая")
      end
      cmd.subcommand(:show, "Показать предупреждения пользователя") do |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
      end
      cmd.subcommand(:clear, "Убрать все предупреждения пользователя") do |subcmd|
        subcmd.user(:user, "Выберите пользователя", required: true)
      end
      cmd.subcommand(:drop, "Сбросить базу данных предупреждений для этого сервера")
    end
  end

  #manage-messages permission
  def self.handle(bot)
    bot.application_command(:warnings).subcommand(:new) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      count = Database.insert_warning(handler.server_id.to_s, handler.options["user"].to_s, handler.options["reason"], handler.user.id.to_s, Time.now.to_i)
      count += 1
      if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == true
        if handler.options["reason"].length < 256
          embed = Discordrb::Webhooks::Embed.new
          embed.color = 13775422
          if count < 5
            if lang == "ru"
              embed.description = "**Пользователь <@#{handler.options["user"]}> предупрежден**\nЭто случай №#{count}"
              embed.add_field(name: "Причина", value: handler.options["reason"], inline: false)
            else
              embed.description = "**User <@#{handler.options["user"]}> has been warned**\nThis is case №#{count}"
              embed.add_field(name: "Reason", value: handler.options["reason"], inline: false)
            end
            handler.respond(embeds: [] << embed)
          else
            if lang == "ru"
              embed.description = "**Пользователь достиг лимита из 5 предупреждений**"
            else
              embed.description = "**The user has reached the limit of 5 warnings**"
            end
            handler.respond(embeds: [] << embed)
          end
        else
          if lang == "ru"
            handler.respond(content: "Максимальная длина причины предупреждения 256 символов")
          else
            handler.respond(content: "Max warning reason length is 256 symbols")
          end
        end
      else
        if lang == "ru"
          handler.respond(content: "У вас нет прав уровня <управление сообщениями> на этом сервере", ephemeral: true)
        else
          handler.respond(content: "You don't have <manage messages> permission on this server", ephemeral: true)
        end
      end
    end

    bot.application_command(:warnings).subcommand(:show) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == true
        embed = Discordrb::Webhooks::Embed.new
        embed.color = 13775422
        data = Database.get_warnings(handler.server_id.to_s, handler.options["user"].to_s)
        i = 1
        if data[0] > 0
          if lang == "ru"
            embed.description = "**Предупреждения пользователя** <@#{handler.options["user"]}>"
            data[1].each do |warn|
              embed.add_field(name: "Случай №#{i}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
              i += 1
            end
          else
            embed.description = "**Warnings for user** <@#{handler.options["user"]}>"
            data[1].each do |warn|
              embed.add_field(name: "Case №#{i}", value: "Reason: #{warn[0]}\nBy: <@#{warn[1]}>\nTimestamp: <t:#{warn[2]}>\n[Expires in #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} days]", inline: true)
              i += 1
            end
          end
        else
          if lang == "ru"
            embed.description = "**У пользователя <@#{handler.options["user"]}> нет предупреждений**"
          else
            embed.description = "**User <@#{handler.options["user"]}> has no warnings**"
          end
        end
        handler.respond(embeds: [] << embed)
      else
        if lang == "ru"
          handler.respond(content: "У вас нет прав уровня <управление сообщениями> на этом сервере", ephemeral: true)
        else
          handler.respond(content: "You don't have <manage messages> permission on this server", ephemeral: true)
        end
      end
    end
    #handle 0
    bot.application_command(:warnings).subcommand(:remove) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      number = handler.options["number"].nil? ? nil : handler.options["number"]
      unless number.nil?
        number = nil if number > 5 or number < 1
      end
      if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == true
        deleted_number = Database.remove_warning(handler.server_id.to_s, handler.options["user"].to_s, number)
        embed = Discordrb::Webhooks::Embed.new
        embed.color = 13775422
        if deleted_number.nil? or deleted_number == 0
          if lang == "ru"
            embed.description = "**У пользователя <@#{handler.options["user"]}> нет предупреждений**"
          else
            embed.description = "**User <@#{handler.option["user"]}> has no warnings**"
          end
        else
          if lang == "ru"
            embed.description = "**Убрано предупреждение №#{deleted_number} у пользователя** <@#{handler.options["user"]}>"
          else
            embed.description = "**Removed warning №#{deleted_number} for user** <@#{handler.options["user"]}>"
          end
        end
        handler.respond(embeds: [] << embed)
      else
        if lang == "ru"
          handler.respond(content: "У вас нет прав уровня <управление сообщениями> на этом сервере", ephemeral: true)
        else
          handler.respond(content: "You don't have <manage messages> permission on this server", ephemeral: true)
        end
      end
    end

    bot.application_command(:warnings).subcommand(:clear) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == true
        embed = Discordrb::Webhooks::Embed.new
        embed.color = 13775422
        Database.clear_warnings(handler.server_id.to_s, handler.options["user"].to_s)
        if lang == "ru"
          embed.description = "**Убраны все предупреждения пользователя** <@#{handler.options["user"]}>"
        else
          embed.description = "**Removed all warnings for user** <@#{handler.options["user"]}>"
        end
        handler.respond(embeds: [] << embed)
      else
        if lang == "ru"
          handler.respond(content: "У вас нет прав уровня <управление сообщениями> на этом сервере", ephemeral: true)
        else
          handler.respond(content: "You don't have <manage messages> permission on this server", ephemeral: true)
        end
      end
    end

    bot.application_command(:warnings).subcommand(:drop) do |handler|
      lang = Utils.get_language(handler.server_id.to_s)
      if bot.member(handler.server_id, handler.user.id).permission?(:administrator) == true
        embed = Discordrb::Webhooks::Embed.new
        embed.color = 13775422
        Database.drop_warnings(handler.server_id.to_s)
        if lang == "ru"
          embed.description = "**Сброшены все данные о предупреждениях на данном сервере**"
        else
          embed.description = "**Dropped all data about warnings on this server**"
        end
        handler.respond(embeds: [] << embed)
      else
        if lang == "ru"
          handler.respond(content: "У вас нет прав уровня <администратор> на этом сервере", ephemeral: true)
        else
          handler.respond(content: "You don't have <администратор> permission on this server", ephemeral: true)
        end
      end
    end
  end
end
