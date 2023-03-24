require_relative "../EventsHandler.rb"
require_relative "../MessageLogger.rb"

message_edit_event = proc { |handler|
  handler.message_edit { |event|
    begin
      return if event.server.nil?
      size = event.message&.content&.size.nil? ? 0 : event.message.content.size
      return if size > 1024
      data = {
        :id => event.message.id,
        :author => event.message.author,
        :content => event.message.content,
        :channel => event.message.channel.id,
        :link => event.message.link,
        :attachment => event.message.attachments.first&.url,
      }
      MessageLogger.edit_message(event.server.id, event.message.id, data)
    rescue LocalJumpError;     end
  }
}

EventsHandler.add_handler(message_edit_event)
