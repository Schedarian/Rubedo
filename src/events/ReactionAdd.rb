require_relative "../EventsHandler.rb"
require_relative "../StarboardHandler.rb"

reaction_add_event = proc { |handler|
  handler.reaction_add { |event|
    begin
      return if event.server.nil?
      StarboardHandler.star_added(event) if event.emoji.name == "⭐"
    rescue LocalJumpError;     end
  }
}

EventsHandler.add_handler(reaction_add_event)
