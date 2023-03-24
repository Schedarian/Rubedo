require_relative "../EventsHandler.rb"
require_relative "../MessageLogger.rb"

message_delete_event = proc { |handler|
  begin
    handler.message_delete { |event|
      return if event.channel.server.nil?
      MessageLogger.delete_message(event.channel.server.id, event.id)
    }
  rescue LocalJumpError;   end
}

EventsHandler.add_handler(message_delete_event)
