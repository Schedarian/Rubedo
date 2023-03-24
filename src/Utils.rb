# Some useful utilities, such as parsing and qol things

class String # I don't remember why is this here
  def numeric?()
    Float(self) != nil rescue false
  end
end

module Utils
  def self.load_languages
    return JSON.parse(File.read("data/languages.json"))
  end

  def self.update_languages(languages)
    File.write("data/languages.json", languages.to_json)
  end

  def self.valid_json?(json)
    JSON.parse(json) rescue nil
  end
end
