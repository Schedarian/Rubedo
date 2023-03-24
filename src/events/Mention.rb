require_relative "../EventsHandler.rb"

mention_event = proc { |handler|
 #handler.mention { |event| }
  }

EventsHandler.add_handler(mention_event)
