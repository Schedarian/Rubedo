# Some useful features

class String
  def numeric?()
    Float(self) != nil rescue false
  end
end

module Utils
  def self.get_language(server)
    return JSON.parse(File.read("#{Dir.pwd}/data/languages.json"))[server]
  end

  def self.parse_status(status, lang)
    if lang == "ru"
      case status
      when :online
        return "В сети"
      when :idle
        return "Не активен"
      when :dnd
        return "Не беспокоить"
      when :offline, nil
        return "Не в сети"
      end
    else
      case status
      when :online
        return "Online"
      when :idle
        return "Idle"
      when :dnd
        return "Do not disturb"
      when :offline, nil
        return "Offline"
      end
    end
  end

  def self.parse_verification_level(level, lang)
    if lang == "ru"
      case level
      when :none
        return "Отсутствует"
      when :low
        return "Низкий"
      when :medium
        return "Средний"
      when :high
        return "Высокий"
      when :very_high
        return "Очень высокий"
      end
    else
      case level
      when :none
        return "None"
      when :low
        return "Low"
      when :medium
        return "Medium"
      when :high
        return "High"
      when :very_high
        return "Very high"
      end
    end
  end

  def self.parse_content_filtering(level, lang)
    if lang == "ru"
      case level
      when :disabled
        return "Выключена"
      when :members_without_roles
        return "Пользователи без ролей"
      when :all_members
        return "Для всех пользователей"
      end
    else
      case level
      when :disabled
        return "Disabled"
      when :members_without_roles
        return "Users without a role"
      when :all_members
        return "All users"
      end
    end
  end
end
