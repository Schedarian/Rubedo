require "yaml"

module Config
  CFG = YAML.load(File.read("config.yaml"))

  def self.get_token
    return CFG["token"]
  end

  def self.get_weather_token
    return CFG["weathertoken"]
  end
end
