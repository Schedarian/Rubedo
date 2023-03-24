# Nothing special here, just config constants

require "yaml"

module Config
  CONFIG = YAML.load(File.read("config.yaml"))

  BOT_TOKEN = CONFIG["bot_token"]

  BOT_ID = CONFIG["bot_id"]

  WEATHER_TOKEN = CONFIG["weather_token"]

  DEFAULT_EMBED_COLOR = CONFIG["default_embed_color"]

  DEVELOPER_ID = CONFIG["developer_id"]

  REGISTER_GLOBAL = CONFIG["register_global"]

  START_TIME = Time.now.to_i
end
