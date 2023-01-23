require_relative "../Utils.rb"

module Eightball
  include Utils

  def self.register_en(bot, server)
    bot.register_application_command("8ball", "Ask the magic ball", server_id: server) do |cmd|
      cmd.string(:question, "Type in a question", required: true)
    end
  end

  def self.register_ru(bot, server)
    bot.register_application_command(:"8ball", "Спросить магический шар", server_id: server) do |cmd|
      cmd.string(:question, "Задайте вопрос", required: true)
    end
  end

  def self.handle(bot)
    bot.application_command(:"8ball") do |handler|
      lang = Utils.get_language(handler.server_id.to_s)

      if lang == "ru"
        response = ["Это точно",
                    "Без сомнения",
                    "Можете положиться на это",
                    "Да, безусловно",
                    "Это несомненно так",
                    "Как я вижу, да",
                    "Скорей всего",
                    "Да",
                    "Исход благоприятен",
                    "Признаки указывают на <да>",
                    "Пока не ясно, попробуй снова",
                    "Лучше не говорить об этом сейчас",
                    "Спроси снова позже",
                    "Не могу предсказать сейчас",
                    "Сконцентрируйся и спроси еще раз",
                    "Не рассчитывай на это",
                    "Исход не такой благоприятный",
                    "Мои источники говорят <нет>",
                    "Весьма сомнительно",
                    "Мой ответ - нет"]
        handler.respond(content: "***#{response.sample}***")
      else
        response = ["It is certain",
                    "Without a doubt",
                    "You may rely on it",
                    "Yes definitely",
                    "It is decidedly so",
                    "As I see it, yes",
                    "Most likely",
                    "Yes",
                    "Outlook good",
                    "Signs point to yes",
                    "Reply hazy try again",
                    "Better not tell you now",
                    "Ask again later",
                    "Cannot predict now",
                    "Concentrate and ask again",
                    "Don't count on it",
                    "Outlook not so good",
                    "My sources say no",
                    "Very doubtful",
                    "My reply is no"]
        handler.respond(content: "***#{response.sample}***")
      end
    end
  end
end
