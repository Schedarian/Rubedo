require_relative "../EventsHandler.rb"
require_relative "../MessageLogger.rb"

message_create_event = proc { |handler|
  handler.message { |event|
    begin
      return if event.server.nil?
      size = event.message&.content&.size.nil? ? 0 : event.message.content.size
      return if size > 1024 # Skip huge messages
      data = {
        :id => event.message.id,
        :author => event.message.author,
        :content => event.message.content,
        :channel => event.message.channel.id,
        :link => event.message.link,
        :attachment => event.message.attachments.first&.url,
      }

      MessageLogger.log_message(event.server.id, data)
    rescue LocalJumpError;     end
  }
}

EventsHandler.add_handler(message_create_event)
