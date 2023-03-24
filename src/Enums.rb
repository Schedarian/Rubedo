# Ruby does not have enums, so I am making boilerplate plus some hashes

module Enums
  WEATHER_RU = {
    "Гроза с лёгким дождём" => 200,
    "Гроза с дождём" => 201,
    "Гроза с сильным дождём" => 202,
    "Лёгкая гроза" => 210,
    "Гроза" => 211,
    "Сильная гроза" => 212,
    "Периодическая гроза" => 221,
    "Гроза с лёгкой моросью" => 230,
    "Гроза с моросью" => 231,
    "Гроза с сильной моросью" => 232,
    "Мелкая морось" => 300,
    "Морось" => 301,
    "Сильная морось" => 302,
    "Лёгкий моросящий дождь" => 310,
    "Моросящий дождь" => 311,
    "Сильный моросящий дождь" => 312,
    "Ливень с изморосью" => 313,
    "Сильный ливень с изморосью" => 314,
    "Моросящий ливень" => 321,
    "Лёгкий дождь" => 500,
    "Умеренный дождь" => 501,
    "Сильный дождь" => 502,
    "Очень сильный дождь" => 503,
    "Невероятно сильный дождь" => 504,
    "Холодный дождь" => 511,
    "Слабый ливень" => 520,
    "Ливень" => 521,
    "Сильный ливень" => 522,
    "Периодический ливень" => 531,
    "Лёгкий снег" => 600,
    "Снег" => 601,
    "Сильный снег" => 602,
    "Мокрый снег" => 611,
    "Лёгкий мокрый снег" => 612,
    "Ливень с мокрым снегом" => 613,
    "Лёгкий дождь со снегом" => 615,
    "Дождь со снегом" => 616,
    "Лёгкий снегопад" => 620,
    "Снегопад" => 621,
    "Сильный снегопад" => 622,
    "Лёгкий туман" => 701,
    "Дымка" => 711,
    "Мгла" => 721,
    "Пылевые вихри" => 731,
    "Туман" => 741,
    "Песок" => 751,
    "Пыль" => 761,
    "Вулканический пепел" => 762,
    "Шквал" => 771,
    "Торнадо" => 781,
    "Ясно" => 800,
    "Лёгкая облачность" => 801,
    "Рассеяная облачность" => 802,
    "Переменная облачность" => 803,
    "Облачность" => 804,
  }.freeze

  DISCORD_STATUS_EN = {
    :online => "Online",
    :idle => "Idle",
    :dnd => "Dnd",
    :offline => "Offline",
    nil => "Offline",
  }.freeze

  DISCORD_STATUS_RU = {
    :online => "В сети",
    :idle => "Не активен",
    :dnd => "Не беспокоить",
    :offline => "Не в сети",
    nil => "Не в сети",
  }.freeze

  DISCORD_VERIFICATION_LEVEL_EN = {
    :none => "None",
    :low => "Low",
    :medium => "Medium",
    :high => "High",
    :very_high => "Very High",
  }.freeze

  DISCORD_VERIFICATION_LEVEL_RU = {
    :none => "Отсутствует",
    :low => "Низкий",
    :medium => "Средний",
    :high => "Высокий",
    :very_high => "Очень высокий",
  }.freeze

  DISCORD_CONTENT_FILTERS_EN = {
    :disabled => "Disabled",
    :members_without_roles => "Users without a role",
    :all_members => "All users",
  }.freeze

  DISCORD_CONTENT_FILTERS_RU = {
    :disabled => "Выключена",
    :members_without_roles => "Пользователи без ролей",
    :all_members => "Для всех пользователей",
  }.freeze

  DISCORD_PERMISSIONS_EN = {
    :administrator => "Administrator",
    :ban_members => "Ban members",
    :kick_members => "Kick members",
    :manage_server => "Manage server",
    :manage_channels => "Manage channels",
    :manage_messages => "Manage messages",
  }.freeze

  DISCORD_PERMISSIONS_RU = {
    :administrator => "Администратор",
    :ban_members => "Бан пользователей",
    :kick_members => "Кик пользователей",
    :manage_server => "Управление сервером",
    :manage_channels => "Управление каналами",
    :manage_messages => "Управление сообщениями",
  }
end
