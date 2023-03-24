# Fired when bot joins the server

require_relative "../Database.rb"
require_relative "../EventsHandler.rb"
require_relative "../StarboardHandler.rb"
require_relative "../MessageLogger.rb"

server_create_event = proc { |handler|
  handler.server_create { |event|
    # Check if db for that server exists, create default settings
    Database.check_db(handler)
    StarboardHandler.add_server(event.server.id)
  }
}

EventsHandler.add_handler(server_create_event)
