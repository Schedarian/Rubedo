module EventsHandler
  @@bot = nil
  @@handlers = [] # List of handlers

  def self.set(bot)
    @@bot = bot
  end

  def self.add_handler(handler)
    @@handlers << handler
  end

  def self.handle_events
    @@handlers.each { |handler|
      handler.call(@@bot)
    }
  end
end
